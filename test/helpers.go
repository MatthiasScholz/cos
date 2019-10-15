package test

// This file contains helper functions to evaluate the functionality
// of the terraform modules.

import (
	"crypto/x509"
	"encoding/pem"
	"errors"
	"fmt"
	"io/ioutil"
	"net/http"
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
	"github.com/stretchr/testify/assert"

	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	consul_api "github.com/hashicorp/consul/api"
	nomad_api "github.com/hashicorp/nomad/api"
)

var forbiddenRegions = []string{
	"ap-northeast-1", // Subnet ap-northeast-1b not supported
	"sa-east-1",      // Subnet asa-east-1b not supported
}

const savedAWSRegion = "AwsRegion"

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

func helperSetupInfrastructure(t *testing.T, awsRegion string, tmpPath string, ami bool) {
	uniqueID := random.UniqueId()

	keyPairName := fmt.Sprintf("terratest-onetime-key-%s", uniqueID)
	keyPair := aws.CreateAndImportEC2KeyPair(t, awsRegion, keyPairName)

	terraformOptions := initTerraformOptions(tmpPath)
	terraformOptions.Vars["aws_region"] = awsRegion
	terraformOptions.Vars["ssh_key_name"] = keyPairName
	if ami {
		amiID := test_structure.LoadAmiId(t, tmpPath)
		terraformOptions.Vars["ami_id"] = amiID
	}

	// Persist options and keypair for later use
	test_structure.SaveTerraformOptions(t, tmpPath, terraformOptions)
	test_structure.SaveEc2KeyPair(t, tmpPath, keyPair)

	// Rollout infrastructure
	terraform.InitAndApply(t, terraformOptions)
}

func helperCleanup(t *testing.T, tmpPath string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, tmpPath)
	terraform.Destroy(t, terraformOptions)

	keyPair := test_structure.LoadEc2KeyPair(t, tmpPath)
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
		// DEBUG: helperExportSSHKey(publicHost.SshKeyPair)

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
			"aws_region": awsRegion,
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
func helperExportSSHKey(keyPair *ssh.KeyPair) error {

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

func helperCheckUI(t *testing.T, terraformOptions *terraform.Options, terraformOutput string, expected string) {
	maxRetries := 60
	sleepBetweenRetries := 10 * time.Second

	urlUI := terraform.Output(t, terraformOptions, terraformOutput)
	// DEBUG: logger.Logf(t, "'%s': '%s'", terraformOutput, urlUI)

	retry.DoWithRetry(t, "Check nomad members", maxRetries, sleepBetweenRetries, func() (string, error) {
		respUI, err := http.Get(urlUI)
		if err != nil {
			return "", err
		}

		defer respUI.Body.Close()

		bodyBytes, err := ioutil.ReadAll(respUI.Body)
		if err != nil {
			return "", err
		}
		respUIBody := string(bodyBytes)
		assert.Equal(t, http.StatusOK, respUI.StatusCode)
		assert.Contains(t, respUIBody, expected)

		return "", nil
	})

}

// Use a Nomad client to connect to the given node and use it to verify that:
//
// 1. The Nomad cluster has deployed
// 2. The cluster has the expected number of members
// 3. The cluster has elected a leader
func helperTestNomadCluster(t *testing.T, nodeIPAddress string, expectedServers int, expectedNodes int) {
	nomadClient := helperCreateNomadClient(t, fmt.Sprintf("http://%s", nodeIPAddress))
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
			return "", errors.New("Nomad cluster returned an empty leader response, so a leader must not have been elected yet")
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
func helperTestConsulCluster(t *testing.T, nodeIPAddress string, expectedMembers int) {
	consulClient := helperCreateConsulClient(t, nodeIPAddress)
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
			return "", errors.New("Consul cluster returned an empty leader response, so a leader must not have been elected yet")
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

func helperCheckNomad(t *testing.T, publicIP string, keyPair *aws.Ec2Keypair) {

	publicHost := ssh.Host{
		Hostname:    publicIP,
		SshKeyPair:  keyPair.KeyPair,
		SshUserName: "ec2-user",
	}

	// Check basic nomad commands directly on the created instances
	retry.DoWithRetry(t, "Check nomad on created host/ server", 30, 5*time.Second, func() (string, error) {
		// DEBUG: helperExportSSHKey(publicHost.SshKeyPair)

		// Check the status of the nomad setup
		expectedLeader := "No running jobs"
		commandLeader := "nomad status"
		actualText, errLeader := ssh.CheckSshCommandE(t, publicHost, commandLeader)

		// .Verify result
		if errLeader != nil {
			return "", fmt.Errorf("Msg: %s, Command %s executed with error: %v", actualText, commandLeader, errLeader)
		}
		if strings.Contains(actualText, expectedLeader) == false {
			return "", fmt.Errorf("Expected status report to be '%s' but got '%s'", expectedLeader, actualText)
		}

		// Check if there is a leader elected
		expectedMembers := "leader"
		commandMembers := "nomad operator raft list-peers"
		actualText, errMembers := ssh.CheckSshCommandE(t, publicHost, commandMembers)

		// .Verify result
		if errMembers != nil {
			return "", fmt.Errorf("Msg: %s Command %s executed with error: %v", actualText, commandMembers, errMembers)
		}
		if strings.Contains(actualText, expectedMembers) == false {
			return "", fmt.Errorf("Expected leader report to be '%s' but got '%s'", expectedLeader, actualText)
		}

		return "", nil
	})
}
