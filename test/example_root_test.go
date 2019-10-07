// This files contains test to evaluation the functionality
// of the Root example.
package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	nomad_jobspec "github.com/hashicorp/nomad/jobspec"
	"github.com/stretchr/testify/require"

	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

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
