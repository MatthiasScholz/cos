// This files contains test to evaluation the functionality
// of the Nomad-Datacenter example.
package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestNomadDataCenterExample(t *testing.T) {
	tmpNomadDataCenter := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/nomad-datacenter")
	awsRegion := "us-east-1"

	// Create AMI
	test_structure.RunTestStage(t, "setup_ami", func() {
		// Execution from inside the test folder
		amiName := "amazon-linux-ami2"
		amiId := helperBuildAmi(t, "../modules/ami2/nomad-consul-docker-ecr.json", amiName, awsRegion)

		test_structure.SaveString(t, tmpNomadDataCenter, savedAWSRegion, awsRegion)
		test_structure.SaveAmiId(t, tmpNomadDataCenter, amiId)
	})

	// Cleanup
	defer test_structure.RunTestStage(t, "teardown", func() {
		helperCleanup(t, tmpNomadDataCenter)

		// Delete the generated AMI
		amiId := test_structure.LoadAmiId(t, tmpNomadDataCenter)
		awsRegion := test_structure.LoadString(t, tmpNomadDataCenter, savedAWSRegion)
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
