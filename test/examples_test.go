package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"

	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

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

func TestBastionExample(t *testing.T) {

	// Keep repository clean
	// HINT: In combination with a more flexible AWS region choice this can be used to run tests in parallel.
	tmpBastion := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/bastion")

	// Cleanup infrastructure and ssh key
	defer test_structure.RunTestStage(t, "teardown", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, tmpBastion)
		terraform.Destroy(t, terraformOptions)

		keyPair := test_structure.LoadEc2KeyPair(t, tmpBastion)
		aws.DeleteEC2KeyPair(t, keyPair)
	})

	// Prepare infrastructure and create it
	test_structure.RunTestStage(t, "setup", func() {
		// Fixing the region is a flaw - but since this is only testing the examples it is acceptable.
		// HINT: terratest provides a more flexible approach using: aws.GetRandomStableRegion()
		awsRegion := "us-east-1"
		keyPairName := "terratest-onetime-key"
		keyPair := aws.CreateAndImportEC2KeyPair(t, awsRegion, keyPairName)

		terraformOptions := initTerraformOptions(tmpBastion)
		terraformOptions.Vars["aws_region"] = awsRegion
		terraformOptions.Vars["ssh_key_name"] = keyPairName

		// Persist options and keypair for later use
		test_structure.SaveTerraformOptions(t, tmpBastion, terraformOptions)
		test_structure.SaveEc2KeyPair(t, tmpBastion, keyPair)

		// Rollout infrastructure
		terraform.InitAndApply(t, terraformOptions)
	})

	// Check SSH access into the Bastion
	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, tmpBastion)
		keyPair := test_structure.LoadEc2KeyPair(t, tmpBastion)

		// Get public IP
		publicIP := terraform.Output(t, terraformOptions, "bastion_ip")

		publicHost := ssh.Host{
			Hostname:    publicIP,
			SshKeyPair:  keyPair.KeyPair,
			SshUserName: "ec2-user",
		}

		// Check basic SSH to the instance
		retry.DoWithRetry(t, "SSH to public host", 30, 5*time.Second, func() (string, error) {
			expectedText := "Hello, Bastion"
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
	})
}

func TestNetworkingExample(t *testing.T) {

	tmpNetworking := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/networking")

	// Cleanup infrastructure
	defer test_structure.RunTestStage(t, "teardown", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, tmpNetworking)
		terraform.Destroy(t, terraformOptions)
	})

	// Prepare infrastructure and create it
	test_structure.RunTestStage(t, "setup", func() {
		// TODO Not sure it is a good pattern in regards to have reproducible runs.
		//      It might be better to run the test in all regions which should be supported.
		awsRegion := aws.GetRandomStableRegion(t, nil, forbiddenRegions)

		terraformOptions := initTerraformOptions(tmpNetworking)
		terraformOptions.Vars["aws_region"] = awsRegion

		// Persist options and keypair for later use
		test_structure.SaveTerraformOptions(t, tmpNetworking, terraformOptions)

		// Rollout infrastructure
		terraform.InitAndApply(t, terraformOptions)
	})

	// Check infrastructure
	// - examples has no outputs!
	// -> For now it is just important that the examples successfully ran.
}
