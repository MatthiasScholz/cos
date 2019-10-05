package test

import (
	"crypto/x509"
	"encoding/pem"
	"errors"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/packer"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"
	consul_api "github.com/hashicorp/consul/api"
	nomad_api "github.com/hashicorp/nomad/api"
	nomad_jobspec "github.com/hashicorp/nomad/jobspec"
	"github.com/knq/pemutil"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

const SAVED_AWS_REGION = "AwsRegion"

// FIXME: this seems to be odd - how often is this constant used?
const CONSUL_AMI_TEMPLATE_VAR_REGION = "aws_region"

var forbiddenRegions = []string{
	"ap-northeast-1", // Subnet ap-northeast-1b not supported
}

func initTerraformOptions(path string) *terraform.Options {
	terraformOptions := &terraform.Options{
		// Path to terraform code
		TerraformDir: path,

		// Vars for terraform
		Vars: map[string]interface{}{
			"deploy_profile": "default",
		},

		// Disable coloring by terraform to facilitate output parsing
		NoColor: true,
	}

	return terraformOptions
}

func helperSetupInfrastructure(t *testing.T, awsRegion string, tmp_path string, ami bool) {
	uniqueID := random.UniqueId()

	keyPairName := fmt.Sprintf("terratest-onetime-key-%s", uniqueID)
	keyPair := aws.CreateAndImportEC2KeyPair(t, awsRegion, keyPairName)

	terraformOptions := initTerraformOptions(tmp_path)
	terraformOptions.Vars["aws_region"] = awsRegion
	terraformOptions.Vars["ssh_key_name"] = keyPairName
	if ami {
		amiId := test_structure.LoadAmiId(t, tmp_path)
		terraformOptions.Vars["ami_id"] = amiId
	}

	// Persist options and keypair for later use
	test_structure.SaveTerraformOptions(t, tmp_path, terraformOptions)
	test_structure.SaveEc2KeyPair(t, tmp_path, keyPair)

	// Rollout infrastructure
	terraform.InitAndApply(t, terraformOptions)
}

func helperCleanup(t *testing.T, tmp_path string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, tmp_path)
	terraform.Destroy(t, terraformOptions)

	keyPair := test_structure.LoadEc2KeyPair(t, tmp_path)
	aws.DeleteEC2KeyPair(t, keyPair)
}

func helperCheckSSH(t *testing.T, publicIP string, keyPair *ssh.KeyPair) {

	publicHost := ssh.Host{
		Hostname:    publicIP,
		SshKeyPair:  keyPair,
		SshUserName: "ec2-user",
	}

	// Check basic SSH to the instance
	retry.DoWithRetry(t, "SSH to public host", 30, 5*time.Second, func() (string, error) {
		expectedText := fmt.Sprintf("Hello, %s", publicIP)
		command := fmt.Sprintf("echo -n '%s'", expectedText)
		actualText, err := ssh.CheckSshCommandE(t, publicHost, command)

		if err != nil {
			return "", err
		}

		if strings.TrimSpace(actualText) != expectedText {
			return "", fmt.Errorf("Expected SSH command to return '%s' but got '%s'", expectedText, actualText)
		}

		return "", nil
	})
}

func helperCheckConsul(t *testing.T, publicIP string, keyPair *aws.Ec2Keypair) {

	publicHost := ssh.Host{
		Hostname:    publicIP,
		SshKeyPair:  keyPair.KeyPair,
		SshUserName: "ec2-user",
	}

	// Check basic SSH to the instance
	retry.DoWithRetry(t, "SSH to public host", 30, 5*time.Second, func() (string, error) {
		// DEBUG: helperExportSshKey(publicHost.SshKeyPair)

		// Check system service configuration: supervisor started consul service and consul is running
		expectedService := "RUNNING"
		commandService := "sudo supervisorctl status consul"
		actualText, errService := ssh.CheckSshCommandE(t, publicHost, commandService)

		// .Verify result
		if errService != nil {
			return "", fmt.Errorf("Msg: %s Command %s executed with error: %v", actualText, commandService, errService)
		}
		if strings.Contains(actualText, expectedService) == false {
			return "", fmt.Errorf("Expected systemd consul state to return '%s' but got '%s'", expectedService, actualText)
		}

		// Check if there is a leader elected.
		expectedLeader := "leader"
		commandLeader := "consul operator raft list-peers"
		actualText, errLeader := ssh.CheckSshCommandE(t, publicHost, commandLeader)
		// or with curl:
		// curl http://127.0.0.1:8500/v1/status/leader -> just gives the address of the current leader

		// .Verify result
		if errLeader != nil {
			return "", fmt.Errorf("Msg: %s, Command %s executed with error: %v", actualText, commandLeader, errLeader)
		}
		if strings.Contains(actualText, expectedLeader) == false {
			return "", fmt.Errorf("Expected leader report to be '%s' but got '%s'", expectedLeader, actualText)
		}

		// Check if there are members
		expectedMembers := "alive"
		commandMembers := "consul members"
		actualText, errMembers := ssh.CheckSshCommandE(t, publicHost, commandMembers)
		// or with curl:
		// curl http://127.0.0.1:8500/v1/status/peers

		// .Verify result
		if errMembers != nil {
			return "", fmt.Errorf("Msg: %s Command %s executed with error: %v", actualText, commandMembers, errMembers)
		}
		if strings.Contains(actualText, expectedMembers) == false {
			return "", fmt.Errorf("Expected members report to be '%s' but got '%s'", expectedLeader, actualText)
		}

		return "", nil
	})
}

func helperBuildAmi(t *testing.T, packerTemplatePath string, packerBuildName string, awsRegion string) string {
	options := &packer.Options{
		Template: packerTemplatePath,
		Only:     packerBuildName,
		Vars: map[string]string{
			CONSUL_AMI_TEMPLATE_VAR_REGION: awsRegion,
		},
	}

	amiID := packer.BuildArtifact(t, options)

	logger.Logf(t, "Build AMI with ID: '%s'", amiID)
	// "Build AMI with ID: 'ami-0337d26fe64d95962%!(PACKER_COMMA)us-east-1:ami-02c81da91531dd224'"
	// => FIXME Maybe it is better to remove this kind of configuration from the packer file. This should be specified during the call of packer!

	return amiID
}

// Exports the private SSH key as pem file to the disk.
// This is helpful for debugging sessions when a manual SSH access to the resource is needed.
// The key will be written into the execution folder, named: 'private_key.pem'.
func helperExportSshKey(keyPair *ssh.KeyPair) error {

	store, err := pemutil.DecodeBytes([]byte(keyPair.PrivateKey))
	privateKey, _ := store.RSAPrivateKey()
	var pemPrivateBlock = &pem.Block{
		Type:  "RSA PRIVATE KEY",
		Bytes: x509.MarshalPKCS1PrivateKey(privateKey),
	}

	pemPrivateFile, err := os.Create("private_key.pem")
	err = pem.Encode(pemPrivateFile, pemPrivateBlock)
	if err != nil {
		return err
	}
	pemPrivateFile.Close()

	return nil
}

func TestBastionExample(t *testing.T) {

	// Keep repository clean
	// HINT: In combination with a more flexible AWS region choice this can be used to run tests in parallel.
	tmpBastion := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/bastion")

	// Cleanup infrastructure and ssh key
	defer test_structure.RunTestStage(t, "teardown", func() {
		helperCleanup(t, tmpBastion)
	})

	// Prepare infrastructure and create it
	test_structure.RunTestStage(t, "setup", func() {
		// Fixing the region is a flaw - but since this is only testing the examples it is acceptable.
		// HINT: terratest provides a more flexible approach using: aws.GetRandomStableRegion()
		awsRegion := "us-east-1"
		helperSetupInfrastructure(t, awsRegion, tmpBastion, false)
	})

	// Check SSH access into the Bastion
	test_structure.RunTestStage(t, "validate", func() {
		// Get public IP
		terraformOptions := test_structure.LoadTerraformOptions(t, tmpBastion)
		keyPair := test_structure.LoadEc2KeyPair(t, tmpBastion)
		publicIP := terraform.Output(t, terraformOptions, "bastion_ip")
		helperCheckSSH(t, publicIP, keyPair.KeyPair)
	})
}

// The test is broken into "stages" so you can skip stages by setting environment variables (e.g.,
// skip stage "teardown" by setting the environment variable "SKIP_teardown=true")
func TestConsulExample(t *testing.T) {

	tmpConsul := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/consul")
	awsRegion := "us-east-1"
	amiName := "amazon-linux-ami2"

	// This test needs a custom AMI.
	test_structure.RunTestStage(t, "setup_ami", func() {
		// Execution from inside the test folder
		amiId := helperBuildAmi(t, "../modules/ami2/nomad-consul-docker-ecr.json", amiName, awsRegion)

		// TODO Understand why this is needed - the AMI should be in the same region as the example.
		//      Why can the region information can not be preserved in a different way?
		test_structure.SaveString(t, tmpConsul, SAVED_AWS_REGION, awsRegion)
		test_structure.SaveAmiId(t, tmpConsul, amiId)
	})

	// Cleanup infrastructure
	defer test_structure.RunTestStage(t, "teardown", func() {
		helperCleanup(t, tmpConsul)

		// Delete the generated AMI
		amiId := test_structure.LoadAmiId(t, tmpConsul)
		awsRegion := test_structure.LoadString(t, tmpConsul, SAVED_AWS_REGION)
		aws.DeleteAmi(t, awsRegion, amiId)
	})

	// Prepare infrastructure and create it
	test_structure.RunTestStage(t, "setup", func() {
		helperSetupInfrastructure(t, awsRegion, tmpConsul, true)
	})

	// This module uses a sub module inside. It is tested itself.
	// Hence only basic checks are needed here.
	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, tmpConsul)

		// Check for instance tag
		expectedKey := "consul-servers"
		key := terraform.Output(t, terraformOptions, "consul_servers_cluster_tag_key")

		if key != expectedKey {
			t.Errorf("Expected key: '%s' but got '%s'", expectedKey, key)
		}

		// Check if the consul cluster in working properly
		expectedMembers := 3
		// .Connect via AutoScalingGroup
		awsRegion, _ := terraformOptions.Vars["aws_region"].(string)
		asg := terraform.Output(t, terraformOptions, "asg_name_consul_servers")
		instanceIds := aws.GetInstanceIdsForAsg(t, asg, awsRegion)
		if len(instanceIds) != expectedMembers {
			t.Errorf("Number of AWS instances wrong, expected '%d', but got '%d'.", expectedMembers, len(instanceIds))
		}
		nodeIP := aws.GetPublicIpOfEc2Instance(t, instanceIds[0], awsRegion)

		// Check SSH connection
		keyPair := test_structure.LoadEc2KeyPair(t, tmpConsul)
		helperCheckSSH(t, nodeIP, keyPair.KeyPair)

		// Check if consul service is running
		// - Connections from outside are not allowed!
		// -> Test from inside the cluster needed ( SSH + Commands )
		helperCheckConsul(t, nodeIP, keyPair)
	})
}

func TestNetworkingExample(t *testing.T) {

	tmpNetworking := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/networking")

	// Cleanup infrastructure
	defer test_structure.RunTestStage(t, "teardown", func() {
		helperCleanup(t, tmpNetworking)
	})

	// Prepare infrastructure and create it
	test_structure.RunTestStage(t, "setup", func() {
		// TODO Not sure it is a good pattern in regards to have reproducible runs.
		//      It might be better to run the test in all regions which should be supported.
		awsRegion := aws.GetRandomStableRegion(t, nil, forbiddenRegions)
		helperSetupInfrastructure(t, awsRegion, tmpNetworking, false)
	})

	// Check infrastructure
	// - examples has no outputs!
	// -> For now it is just important that the examples successfully ran.
}

func TestNomadExample(t *testing.T) {
	tmpNomad := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/nomad")
	awsRegion := "us-east-1"

	// Create AMI
	test_structure.RunTestStage(t, "setup_ami", func() {
		// Execution from inside the test folder
		amiName := "amazon-linux-ami2"
		amiId := helperBuildAmi(t, "../modules/ami2/nomad-consul-docker-ecr.json", amiName, awsRegion)

		test_structure.SaveString(t, tmpNomad, SAVED_AWS_REGION, awsRegion)
		test_structure.SaveAmiId(t, tmpNomad, amiId)
	})

	// Cleanup
	defer test_structure.RunTestStage(t, "teardown", func() {
		helperCleanup(t, tmpNomad)

		// Delete the generated AMI
		amiId := test_structure.LoadAmiId(t, tmpNomad)
		awsRegion := test_structure.LoadString(t, tmpNomad, SAVED_AWS_REGION)
		aws.DeleteAmi(t, awsRegion, amiId)
	})

	// Create Infrastructure
	test_structure.RunTestStage(t, "setup", func() {
		helperSetupInfrastructure(t, awsRegion, tmpNomad, true)
	})

	// Validate Example
	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, tmpNomad)
		// TODO Check nomad setup -> ./run_tests.sh
		nomadServerCount, _ := strconv.Atoi(terraform.Output(t, terraformOptions, "num_nomad_servers"))
		nomadClusterTagKey := terraform.Output(t, terraformOptions, "nomad_servers_cluster_tag_key")
		nomadClusterTagValue := terraform.Output(t, terraformOptions, "nomad_servers_cluster_tag_value")
		instanceIds := aws.GetEc2InstanceIdsByTag(t, awsRegion, nomadClusterTagKey, nomadClusterTagValue)

		// Check number of tagged nomad services with report number of terraform
		// -> This is more a dull check, because this would just indicate that terraform itself is not working properly.
		assert.Equal(t, nomadServerCount, len(instanceIds))

		// Check Access to nomad cluster from the outside
		nomadServerIp := aws.GetPublicIpOfEc2Instance(t, instanceIds[0], awsRegion)
		logger.Logf(t, "Nomad Service IP: '%s'", nomadServerIp)

		// TODO Use nomad module to check - no access from the outside to the cluster!
	})
}

func TestNomadDataCenterExample(t *testing.T) {
	tmpNomadDataCenter := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/nomad-datacenter")
	awsRegion := "us-east-1"

	// Create AMI
	test_structure.RunTestStage(t, "setup_ami", func() {
		// Execution from inside the test folder
		amiName := "amazon-linux-ami2"
		amiId := helperBuildAmi(t, "../modules/ami2/nomad-consul-docker-ecr.json", amiName, awsRegion)

		test_structure.SaveString(t, tmpNomadDataCenter, SAVED_AWS_REGION, awsRegion)
		test_structure.SaveAmiId(t, tmpNomadDataCenter, amiId)
	})

	// Cleanup
	defer test_structure.RunTestStage(t, "teardown", func() {
		helperCleanup(t, tmpNomadDataCenter)

		// Delete the generated AMI
		amiId := test_structure.LoadAmiId(t, tmpNomadDataCenter)
		awsRegion := test_structure.LoadString(t, tmpNomadDataCenter, SAVED_AWS_REGION)
		aws.DeleteAmi(t, awsRegion, amiId)
	})

	// Create Infrastructure
	test_structure.RunTestStage(t, "setup", func() {
		helperSetupInfrastructure(t, awsRegion, tmpNomadDataCenter, true)
	})

	// Validate Example
	test_structure.RunTestStage(t, "validate", func() {
		// TODO Check nomad setup -> ./run_tests.sh
		// - not output variables configured
		// - no access from the outside to the cluster
	})
}

func helperCheckUi(t *testing.T, terraformOptions *terraform.Options, terraformOutput string, expected string) {
	urlUi := terraform.Output(t, terraformOptions, terraformOutput)
	// DEBUG: logger.Logf(t, "'%s': '%s'", terraformOutput, urlUi)

	respUi, _ := http.Get(urlUi)
	bodyBytes, _ := ioutil.ReadAll(respUi.Body)
	respUiBody := string(bodyBytes)
	assert.Equal(t, http.StatusOK, respUi.StatusCode)
	assert.Contains(t, respUiBody, expected)
	defer respUi.Body.Close()
}

func TestUIAccessExample(t *testing.T) {
	tmpUIAccess := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/ui-access")
	awsRegion := "us-east-1"

	// Cleanup
	defer test_structure.RunTestStage(t, "teardown", func() {
		helperCleanup(t, tmpUIAccess)
	})

	// Create Infrastructure
	test_structure.RunTestStage(t, "setup", func() {
		helperSetupInfrastructure(t, awsRegion, tmpUIAccess, false)
	})

	// Validate Example
	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, tmpUIAccess)
		// This example has one curl example output for each of the ALB's to access the ui. To test you just have to call it.
		// I.e. the output for nomad ui was ```curl_nomad_ui = curl http://alb-nomad-ui-example-1440612083.us-east-1.elb.amazonaws.com/ui/jobs```, then the call should return ```<h1>Nomad UI</h1>```.
		helperCheckUi(t, terraformOptions, "url_nomad_ui", "Nomad UI")
		helperCheckUi(t, terraformOptions, "url_consul_ui", "Consul UI")
		helperCheckUi(t, terraformOptions, "url_fabio_ui", "Fabio UI")
	})
}

// Use a Nomad client to connect to the given node and use it to verify that:
//
// 1. The Nomad cluster has deployed
// 2. The cluster has the expected number of members
// 3. The cluster has elected a leader
func helperTestNomadCluster(t *testing.T, nodeIpAddress string, expectedServers int, expectedNodes int) {
	nomadClient := helperCreateNomadClient(t, fmt.Sprintf("http://%s", nodeIpAddress))
	maxRetries := 60
	sleepBetweenRetries := 10 * time.Second

	leader := retry.DoWithRetry(t, "Check nomad members", maxRetries, sleepBetweenRetries, func() (string, error) {

		// Check nomad servers
		// cli: nomad server members
		servers, err := nomadClient.Agent().Members()

		if err != nil {
			return "", err
		}

		if len(servers.Members) != expectedServers {
			return "", fmt.Errorf("Expected the cluster to have %d servers, but found %d", expectedServers, len(servers.Members))
		}

		// Check nomad leader
		leader, err := nomadClient.Status().Leader()
		if err != nil {
			return "", err
		}

		if leader == "" {
			return "", errors.New("Nomad cluster returned an empty leader response, so a leader must not have been elected yet.")
		}

		// Check for number of nomad client nodes
		// cli: nomad node status
		nodes, _, err := nomadClient.Nodes().List(nil)

		if err != nil {
			return "", err
		}

		if len(nodes) != expectedNodes {
			return "", fmt.Errorf("Expected the cluster to have %d nodes, but found %d", expectedNodes, len(nodes))
		}

		return leader, nil
	})

	logger.Logf(t, "Nomad cluster is properly deployed and has elected leader %s", leader)
}

// Nomad ALB Client
// ALB maps the ports to the underlying nodes
func helperCreateNomadClient(t *testing.T, ipAddress string) *nomad_api.Client {
	config := nomad_api.DefaultConfig()
	config.Address = ipAddress

	client, err := nomad_api.NewClient(config)
	if err != nil {
		t.Fatalf("Failed to create nomad ALB client due to error: %v", err)
	}

	if config.HttpClient != nil {
		t.Fatalf("Failed to create nomad ALB client due to error - HttpClient")
	}

	//FIXME Crashes - Why? config.HttpClient.Timeout = 5 * time.Second

	return client
}

// Use a Consul client to connect to the given node and use it to verify that:
//
// 1. The Consul cluster has deployed
// 2. The cluster has the expected number of members
// 3. The cluster has elected a leader
func helperTestConsulCluster(t *testing.T, nodeIpAddress string, expectedMembers int) {
	consulClient := helperCreateConsulClient(t, nodeIpAddress)
	maxRetries := 60
	sleepBetweenRetries := 10 * time.Second

	leader := retry.DoWithRetry(t, "Check Consul members", maxRetries, sleepBetweenRetries, func() (string, error) {
		members, err := consulClient.Agent().Members(false)
		if err != nil {
			return "", err
		}

		if len(members) != expectedMembers {
			return "", fmt.Errorf("Expected the cluster to have %d members, but found %d", expectedMembers, len(members))
		}

		leader, err := consulClient.Status().Leader()
		if err != nil {
			return "", err
		}

		if leader == "" {
			return "", errors.New("Consul cluster returned an empty leader response, so a leader must not have been elected yet.")
		}

		return leader, nil
	})

	logger.Logf(t, "Consul cluster is properly deployed and has elected leader %s", leader)
}

// Create a Consul ALB client
func helperCreateConsulClient(t *testing.T, ipAddress string) *consul_api.Client {
	config := consul_api.DefaultConfig()
	config.Address = ipAddress

	client, err := consul_api.NewClient(config)
	if err != nil {
		t.Fatalf("Failed to create Consul client due to error: %v", err)
	}

	config.HttpClient.Timeout = 5 * time.Second

	return client
}

func TestRootExample(t *testing.T) {
	tmpRoot := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/root-example")
	awsRegion := "us-east-1"

	// Create AMI
	test_structure.RunTestStage(t, "setup_ami", func() {
		// Execution from inside the test folder
		amiName := "amazon-linux-ami2"
		amiId := helperBuildAmi(t, "../modules/ami2/nomad-consul-docker-ecr.json", amiName, awsRegion)

		test_structure.SaveString(t, tmpRoot, SAVED_AWS_REGION, awsRegion)
		test_structure.SaveAmiId(t, tmpRoot, amiId)
	})

	// Cleanup
	defer test_structure.RunTestStage(t, "teardown", func() {
		helperCleanup(t, tmpRoot)

		// Delete the generated AMI
		amiId := test_structure.LoadAmiId(t, tmpRoot)
		awsRegion := test_structure.LoadString(t, tmpRoot, SAVED_AWS_REGION)
		aws.DeleteAmi(t, awsRegion, amiId)
	})

	// Create Infrastructure
	test_structure.RunTestStage(t, "setup", func() {
		helperSetupInfrastructure(t, awsRegion, tmpRoot, true)
	})

	// Validate Infrastructure and general cluster health
	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, tmpRoot)
		// Get nomad access via ALB and check basic setup ( members, leader )
		nomadURI := terraform.Output(t, terraformOptions, "nomad_ui_alb_dns")
		helperTestNomadCluster(t, nomadURI, 3, 4)

		// Consul ( members, leader )
		consulURI := terraform.Output(t, terraformOptions, "consul_ui_alb_dns")
		helperTestConsulCluster(t, consulURI, 10) // nomad server + client + consul server
	})

	// Setup nomad cluster
	test_structure.RunTestStage(t, "setup_cluster", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, tmpRoot)
		nomadURI := terraform.Output(t, terraformOptions, "nomad_ui_alb_dns")
		c := helperCreateNomadClient(t, nomadURI) // connect to the cluster
		jobs := c.Jobs()                          // get jobs

		// Check if current number of jobs is zero
		resp, _, err := jobs.List(nil)
		require.Nil(t, err)                                            // Check no error
		require.Emptyf(t, resp, "expected 0 jobs, got: %d", len(resp)) // Check empty job listing

		// Create new job - fabio
		jobFabio, err := nomad_jobspec.ParseFile("../examples/jobs/fabio.nomad")
		require.NoError(t, err)
		require.NotNil(t, jobFabio)
		resp2, _, err := jobs.Register(jobFabio, nil)
		require.NoError(t, err)
		require.NotNil(t, resp2)
		require.NotEmpty(t, resp2.EvalID)
	})

	// TODO Further testing of the cluster.
	// TODO deploy ping_service -> nomad job run
	// TODO Check for external access support

	// TODO Validate Cluster
	// test service ( + retries )
	// tf out: ingress_alb_dns
	// curl -s http://$IG_ALB_DNS/ping -> Status Code: 200
}
