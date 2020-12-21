package test

// This file contains helper functions to evaluate the functionality
// of the terraform modules.

import (
	"fmt"
	"io/ioutil"
	"net/http"
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
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

var forbiddenRegions = []string{
	"ap-northeast-1", // Subnet ap-northeast-1b not supported
	"sa-east-1",      // Subnet sa-east-1b not supported
	"ca-central-1",   // Subnet ca-central-1c not supported
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

func helperSetupInfrastructure(t *testing.T, awsRegion string, tmpPath string, ami bool, ssh bool) {
	uniqueID := random.UniqueId()

	terraformOptions := initTerraformOptions(tmpPath)
	terraformOptions.Vars["aws_region"] = awsRegion

	if ssh {
		keyPairName := fmt.Sprintf("terratest-onetime-key-%s", uniqueID)
		keyPair := aws.CreateAndImportEC2KeyPair(t, awsRegion, keyPairName)
		terraformOptions.Vars["ssh_key_name"] = keyPairName
		test_structure.SaveEc2KeyPair(t, tmpPath, keyPair)
	}
	if ami {
		amiID := test_structure.LoadAmiId(t, tmpPath)
		terraformOptions.Vars["ami_id"] = amiID
	}

	// Persist options for later use
	test_structure.SaveTerraformOptions(t, tmpPath, terraformOptions)

	// Rollout infrastructure
	terraform.InitAndApply(t, terraformOptions)
}

func helperCleanup(t *testing.T, tmpPath string, region string, ami bool, ssh bool) {
	terraformOptions := test_structure.LoadTerraformOptions(t, tmpPath)
	terraform.Destroy(t, terraformOptions)

	// Delete the generated AMI
	if ami {
		amiID := test_structure.LoadAmiId(t, tmpPath)
		awsRegion := test_structure.LoadString(t, tmpPath, region)
		aws.DeleteAmi(t, awsRegion, amiID)
	}

	// Delete the generated SSH key
	if ssh {
		keyPair := test_structure.LoadEc2KeyPair(t, tmpPath)
		aws.DeleteEC2KeyPair(t, keyPair)
	}
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
func verifyCommand(t *testing.T, awsRegion string, instanceID string, command string, expected string, timeout time.Duration) {
	result := aws.CheckSsmCommand(t, awsRegion, instanceID, command, timeout)
	require.Contains(t, result.Stdout, expected)
	require.Equal(t, result.Stderr, "")
	require.Equal(t, int64(0), result.ExitCode)
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

func helperCheckUI(t *testing.T, terraformOptions *terraform.Options, terraformOutput string, expected string) {
	maxRetries := 60
	sleepBetweenRetries := 10 * time.Second

	urlUI := terraform.Output(t, terraformOptions, terraformOutput)
	// DEBUG: logger.Logf(t, "'%s': '%s'", terraformOutput, urlUI)

	retry.DoWithRetry(t, "Check UI access ("+expected+")", maxRetries, sleepBetweenRetries, func() (string, error) {
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
