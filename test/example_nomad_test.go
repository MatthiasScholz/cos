// This files contains test to evaluation the functionality
// of the Nomad example.
package test

import (
	"strconv"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestNomadExample(t *testing.T) {
	tmpNomad := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/nomad")
	awsRegion := "us-east-1"

	// Create AMI
	test_structure.RunTestStage(t, "setup_ami", func() {
		// Execution from inside the test folder
		amiName := "amazon-linux-ami2"
		amiID := helperBuildAmi(t, "../modules/ami2/nomad-consul-docker-ecr.json", amiName, awsRegion)

		test_structure.SaveString(t, tmpNomad, savedAWSRegion, awsRegion)
		test_structure.SaveAmiId(t, tmpNomad, amiID)
	})

	// Cleanup
	defer test_structure.RunTestStage(t, "teardown", func() {
		helperCleanup(t, tmpNomad, savedAWSRegion, true, false)
	})

	// Create Infrastructure
	test_structure.RunTestStage(t, "setup", func() {
		helperSetupInfrastructure(t, awsRegion, tmpNomad, true, false)
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

		// Check if nomad is running
		helperCheckNomadInstance(t, awsRegion, instanceIds[0])
	})

	logger.Log(t, "############ TestNomadExample [SUCCESS] ####################")
}
