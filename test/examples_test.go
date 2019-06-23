package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
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
