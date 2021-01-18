// This files contains test to evaluation the functionality
// of the Consul example.
package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

// The test is broken into "stages" so you can skip stages by setting environment variables (e.g.,
// skip stage "teardown" by setting the environment variable "SKIP_teardown=true")
func TestConsulExample(t *testing.T) {

	tmpConsul := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/consul")
	awsRegion := "us-east-1"
	amiName := "amazon-linux-ami2"

	// This test needs a custom AMI.
	test_structure.RunTestStage(t, "setup_ami", func() {
		// Execution from inside the test folder
		amiID := helperBuildAmi(t, "../modules/ami2/nomad-consul-docker-ecr.json", amiName, awsRegion)

		// TODO Understand why this is needed - the AMI should be in the same region as the example.
		//      Why can the region information can not be preserved in a different way?
		test_structure.SaveString(t, tmpConsul, savedAWSRegion, awsRegion)
		test_structure.SaveAmiId(t, tmpConsul, amiID)
	})

	// Cleanup infrastructure
	defer test_structure.RunTestStage(t, "teardown", func() {
		helperCleanup(t, tmpConsul, savedAWSRegion, true, false)
	})

	// Prepare infrastructure and create it
	test_structure.RunTestStage(t, "setup", func() {
		helperSetupInfrastructure(t, awsRegion, tmpConsul, true, false)
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

		// Check if consul service is running
		// - Connections from outside are not allowed!
		// -> Test from inside the cluster needed ( SSH + Commands )
		helperCheckConsulInstance(t, awsRegion, nodeIP)
	})
	logger.Log(t, "############ TestConsulExample [SUCCESS] ####################")
}
