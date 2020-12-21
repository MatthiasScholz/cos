package test

import (
	"errors"
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/retry"

	"github.com/stretchr/testify/require"

	nomad_api "github.com/hashicorp/nomad/api"
	nomad_jobspec "github.com/hashicorp/nomad/jobspec"
)

func helperCheckNomadInstance(t *testing.T, awsRegion string, publicIP string) {

	filters := map[string][]string{
		"ip-address": {publicIP},
	}
	instanceID := aws.GetEc2InstanceIdsByFilters(t, awsRegion, filters)[0]

	timeout := 3 * time.Minute
	aws.WaitForSsmInstance(t, awsRegion, instanceID, timeout)


	// Check systemd service
	expectedService := "running"
	commandService := "sudo systemctl status nomad"
	verifyCommand(t, awsRegion, instanceID, commandService, expectedService, timeout)

	// Check for clean status
	expectedStatus := "No running jobs"
	commandStatus := "nomad status"
	verifyCommand(t, awsRegion, instanceID, commandStatus, expectedStatus, timeout)

	// Check for leader
	expectedLeader := "leader"
	commandLeader := "nomad operator raft list-peers"
	verifyCommand(t, awsRegion, instanceID, commandLeader, expectedLeader, timeout)

	// TODO Check for members
}

// Use a Nomad client to connect to the given node and use it to verify that:
//
// 1. The Nomad cluster has deployed
// 2. The cluster has the expected number of members
// 3. The cluster has elected a leader
func helperTestNomadCluster(t *testing.T, nodeIPAddress string, expectedServers int, expectedNodes int) {
	nomadClient := helperCreateNomadClient(t, fmt.Sprintf("http://%s", nodeIPAddress))
	maxRetries := 60
	sleepBetweenRetries := 10 * time.Second

	leader := retry.DoWithRetry(t, "Check nomad members", maxRetries, sleepBetweenRetries, func() (string, error) {

		// Check nomad servers
		// cli: nomad server members
		servers, err := nomadClient.Agent().Members()

		if err != nil {
			return "", err
		}

		if len(servers.Members) != expectedServers {
			return "", fmt.Errorf("Expected the cluster to have %d servers, but found %d", expectedServers, len(servers.Members))
		}

		// Check nomad leader
		leader, err := nomadClient.Status().Leader()
		if err != nil {
			return "", err
		}

		if leader == "" {
			return "", errors.New("Nomad cluster returned an empty leader response, so a leader must not have been elected yet")
		}

		// Check for number of nomad client nodes
		// cli: nomad node status
		nodes, _, err := nomadClient.Nodes().List(nil)

		if err != nil {
			return "", err
		}

		if len(nodes) != expectedNodes {
			return "", fmt.Errorf("Expected the cluster to have %d nodes, but found %d", expectedNodes, len(nodes))
		}

		return leader, nil
	})

	logger.Logf(t, "Nomad cluster is properly deployed and has elected leader %s", leader)
}

// Nomad ALB Client
// ALB maps the ports to the underlying nodes
func helperCreateNomadClient(t *testing.T, ipAddress string) *nomad_api.Client {
	config := nomad_api.DefaultConfig()
	config.Address = ipAddress

	client, err := nomad_api.NewClient(config)
	if err != nil {
		t.Fatalf("Failed to create nomad ALB client due to error: %v", err)
	}

	if config.HttpClient != nil {
		t.Fatalf("Failed to create nomad ALB client due to error - HttpClient")
	}

	//FIXME Crashes - Why? config.HttpClient.Timeout = 5 * time.Second

	return client
}

// Use a Nomad client to connect to the given node and use it to verify that:
//
// 1. A deployment of a service (e.g. fabio) is possible
func helperTestNomadDeployment(t *testing.T, nodeIPAddress string) {
	nomadClient := helperCreateNomadClient(t, fmt.Sprintf("http://%s", nodeIPAddress))
	require.NotNil(t, nomadClient, "Failed to create nomad client")
	maxRetries := 60
	sleepBetweenRetries := 10 * time.Second

	retry.DoWithRetry(t, "Check nomad job deployment", maxRetries, sleepBetweenRetries, func() (string, error) {
		jobs := nomadClient.Jobs() // get jobs
		if jobs == nil {
			return "", fmt.Errorf("nomadClient.Jobs() is nil")
		}

		// Check if current number of jobs is zero
		resp, _, err := jobs.List(nil)
		if err != nil {
			return "", err
		}
		if len(resp) > 0 {
			return "", fmt.Errorf("Expected 0 jobs, got: %d", len(resp))
		}

		// Create new job - fabio
		jobFabio, err := nomad_jobspec.ParseFile("../examples/jobs/fabio.nomad")
		if err != nil {
			return "", err
		}

		resp2, _, err := jobs.Register(jobFabio, nil)
		if err != nil {
			return "", err
		}
		if len(resp2.EvalID) == 0 {
			return "", fmt.Errorf("Expected to get a valid EvalID, but got '%s'", resp2.EvalID)
		}
		return "", nil
	})
}
