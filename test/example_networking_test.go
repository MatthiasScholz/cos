// This files contains test to evaluation the functionality
// of the Networking example.
package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestNetworkingExample(t *testing.T) {

	tmpNetworking := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/networking")

	// Cleanup infrastructure
	defer test_structure.RunTestStage(t, "teardown", func() {
		helperCleanup(t, tmpNetworking)
	})

	// Prepare infrastructure and create it
	test_structure.RunTestStage(t, "setup", func() {
		// TODO Not sure it is a good pattern in regards to have reproducible runs.
		//      It might be better to run the test in all regions which should be supported.
		awsRegion := aws.GetRandomStableRegion(t, nil, forbiddenRegions)
		helperSetupInfrastructure(t, awsRegion, tmpNetworking, false)
	})

	// Check infrastructure
	// - examples has no outputs!
	// -> For now it is just important that the examples successfully ran.
}
