// This files contains test to evaluation the functionality
// of the Bastion example.
package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"

	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

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
