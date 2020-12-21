package test

import (
	"errors"
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/retry"

	consul_api "github.com/hashicorp/consul/api"
)

func helperCheckConsulInstance(t *testing.T, awsRegion string, publicIP string) {

	filters := map[string][]string{
		"ip-address": {publicIP},
	}
	instanceID := aws.GetEc2InstanceIdsByFilters(t, awsRegion, filters)[0]

	timeout := 3 * time.Minute
	aws.WaitForSsmInstance(t, awsRegion, instanceID, timeout)


	// Check systemd service
	expectedService := "running"
	commandService := "sudo systemctl status consul"
	verifyCommand(t, awsRegion, instanceID, commandService, expectedService, timeout)


	// Check for leader
	expectedLeader := "leader"
	commandLeader := "consul operator raft list-peers"
	verifyCommand(t, awsRegion, instanceID, commandLeader, expectedLeader, timeout)

	// Check members
	expectedMembers := "alive"
	commandMembers := "consul members"
	verifyCommand(t, awsRegion, instanceID, commandMembers, expectedMembers, timeout)
}

// Use a Consul client to connect to the given node and use it to verify that:
//
// 1. The Consul cluster has deployed
// 2. The cluster has the expected number of members
// 3. The cluster has elected a leader
func helperTestConsulCluster(t *testing.T, nodeIPAddress string, expectedMembers int) {
	consulClient := helperCreateConsulClient(t, nodeIPAddress)
	maxRetries := 60
	sleepBetweenRetries := 10 * time.Second

	leader := retry.DoWithRetry(t, "Check Consul members", maxRetries, sleepBetweenRetries, func() (string, error) {
		members, err := consulClient.Agent().Members(false)
		if err != nil {
			return "", err
		}

		if len(members) != expectedMembers {
			return "", fmt.Errorf("Expected the cluster to have %d members, but found %d", expectedMembers, len(members))
		}

		leader, err := consulClient.Status().Leader()
		if err != nil {
			return "", err
		}

		if leader == "" {
			return "", errors.New("Consul cluster returned an empty leader response, so a leader must not have been elected yet")
		}

		return leader, nil
	})

	logger.Logf(t, "Consul cluster is properly deployed and has elected leader %s", leader)
}

// Create a Consul ALB client
func helperCreateConsulClient(t *testing.T, ipAddress string) *consul_api.Client {
	config := consul_api.DefaultConfig()
	config.Address = ipAddress

	client, err := consul_api.NewClient(config)
	if err != nil {
		t.Fatalf("Failed to create Consul client due to error: %v", err)
	}

	config.HttpClient.Timeout = 5 * time.Second

	return client
}
