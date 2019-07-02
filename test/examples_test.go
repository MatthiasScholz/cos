package test

import (
	"crypto/x509"
	"encoding/pem"
	"fmt"
	"os"
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
	"github.com/knq/pemutil"

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
