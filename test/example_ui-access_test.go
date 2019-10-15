// This files contains test to evaluation the functionality
// of the UI-Access example.
package test

import (
	"testing"

	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestUIAccessExample(t *testing.T) {
	tmpUIAccess := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/ui-access")
	awsRegion := "us-east-1"

	// Cleanup
	defer test_structure.RunTestStage(t, "teardown", func() {
		helperCleanup(t, tmpUIAccess)
	})

	// Create Infrastructure
	test_structure.RunTestStage(t, "setup", func() {
		helperSetupInfrastructure(t, awsRegion, tmpUIAccess, false)
	})

	// Validate Example
	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, tmpUIAccess)
		// This example has one curl example output for each of the ALB's to access the ui. To test you just have to call it.
		// I.e. the output for nomad ui was ```curl_nomad_ui = curl http://alb-nomad-ui-example-1440612083.us-east-1.elb.amazonaws.com/ui/jobs```, then the call should return ```<h1>Nomad UI</h1>```.
		helperCheckUI(t, terraformOptions, "url_nomad_ui", "Nomad UI")
		helperCheckUI(t, terraformOptions, "url_consul_ui", "Consul UI")
		helperCheckUI(t, terraformOptions, "url_fabio_ui", "Fabio UI")
	})
}
