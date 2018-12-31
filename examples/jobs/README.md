# Overview
Collection of nomad sample jobs.

NOTE:
All jobs are connected to an AWS ECR. This setup is needed since the AMI is only configured to access AWS ECR.
Docker Hub will currently not work!

**In order to use the jobs the AWS Account ID, AWS region and the correct registry URL has to be configured.**

# Nomad

## Troubleshooting
When the web ui or the remote query might not show any error logs try ssh into the instance and use the command line tool to examine log messages:
* `nomad logs -stderr <alloc-id>`

## References
* [Microservices Cluster Demo](https://github.com/microservices-demo/microservices-demo/tree/master/deploy/nomad)


## Development Mode
Local setup for development purposes. This will provide a local Docker registry and a local nomad running.

### Quickstart
```
sudo nomad agent -dev -dc="testing"
# Note: Use a new terminal to preserve log output of the nomad agent.
export NOMAD_ADDR=http://localhost:4646
nomad run registry/creg.nomad
```
### Setup
#### Local Nomad
Start nomad in dev mode and configure the datacenter to reflect the actual one once deployed.
* `sudo nomad agent -dev -dc="testing"` ( default dc: "dc1" )

#### Local Docker Registry
1. One time: Configure the Docker daemon to accept local Docker registry. Check the subsections for OS support.
2. Deploy a local Docker registry in the local nomad
   * `nomad run creg.nomad`
   
#### Linux
1. Configuration have to be done at: `/etc/docker/daemon.json`:
```
{
    "insecure-registries" : [ "localhost:5000" ]
}

```
2. Restart the daemon.

#### MacOS
Using the "Docker Desktop" just check out the "Preferences/Daemon" section and add the local Docker registry `localhost:5000` at "Insecure registries".


### Usage
#### Pushing to Docker Registry
```
docker build -t samplejob .
docker tag samplejob:latest localhost:5000/samplejob:latest
docker push localhost:5000/samplejob:latest
```
#### Using with nomad
```
job "samplejob" {
  datacenters = [ "testing" ]
  ...

  group "server" {
    count = 1

    task "registry" {
      driver = "docker"

      config {
        image = "localhost:5000/samplejob:latest"
        ...
      }
    }
  }
}

```


# Fabio
The examples uses fabio as the cluster internal load balances. This has implications on the security group configuration and the ALB configuration.

* Job Type: system

## References
* [Fabio Stip Prefix Feature](https://github.com/fabiolb/fabio/issues/44)

# Ping-Server
Simple golang application to run in the cluster and to check service discovery.

* Job Type: service

# Monitoring
* [Reference](https://www.nomadproject.io/guides/nomad-metrics.html)

## Prometheus
Collect metrics from the COS.

* Job Type: service

* [Nomad Telemetry](https://www.nomadproject.io/docs/agent/telemetry.html)
  * [Enabling](https://www.nomadproject.io/docs/agent/configuration/telemetry.html#prometheus_metrics)
  * [GitHub Feature Discussion](https://github.com/hashicorp/nomad/issues/2528)
* [Service Discovery with Consul](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#<consul_sd_config>)
  * https://misterhex.github.io/Prometheus-and-Consul-for-monitoring-dynamic-services/

List metrics of one specific node in the prometheus format:
`http://<nomad_node>:4646/v1/metrics?format=prometheus`

### Configuration
The goal is to configure prometheus in a way that it will be possible to use Fabio to direct Grafana to the Prometheus instance.
Currently this kind of works for two reasons:
1. Only one Prometheus in running in the cluster.
2. Kind of hacky configuration
   * Configure to start Prometheus with a route-prefix same as used for Fabio.

Prometheus is then reachable via: `http://172.17.0.1:9999/prometheus`

### BUG - Relative URL Handling
Currently it is not possible to use the ALB to get access to the prometheus ui.
It reports gives an incomplete page. Using the direct instance access works as expected.
There seems to be a problem how prometheus is handling the request.
* [Issue 1583](https://github.com/prometheus/prometheus/issues/1583)
* [Issue 2948](https://github.com/prometheus/prometheus/pull/2948)

### TODOs
* [ ] [Use consul to discover nodes dynamically](https://misterhex.github.io/Prometheus-and-Consul-for-monitoring-dynamic-services/)
* [ ] [Consul metrics in prometheus](https://github.com/prometheus/consul_exporter)
* [ ] [Fluentd metrics in promtheus](https://docs.fluentd.org/v0.12/articles/monitoring-prometheus)

## Grafana
Grafana Dashboarding service for metrics as Docker container. Shall visualise COS metrics.

* Job Type: service

* [Docker Install](http://docs.grafana.org/installation/docker/)

### UI
* Default credentials: admin/admin

* [DataSource Configuration](https://prometheus.io/docs/visualization/grafana/#creating-a-prometheus-data-source)
  * [Preconfiguration](http://docs.grafana.org/administration/provisioning/)

* URL: <take_it_from_fabio_ui>
* Access: `proxy`

### BUG - Dashboard Auto Import
Automatic dashboard import not workig.

* [Manual](http://docs.grafana.org/administration/provisioning/#dashboards) -> NOT WORKING ( 2018-03-22 )
* [PR: Feature Implementation](https://github.com/grafana/grafana/pull/10052)

# Logging
Make use of ElasticSearch, Fluentd and Kibana ( EFK ).
* [Nomad Reference](https://www.nomadproject.io/docs/drivers/docker.html#logging)
* [Fluentd EFK](https://docs.fluentd.org/v0.12/articles/docker-logging-efk-compose)
  * [How to with Docker Swarm](https://programmaticponderings.com/2017/04/10/streaming-docker-logs-to-the-elastic-stack-using-fluentd/)
  * [Nomad job configuration](https://www.nomadproject.io/docs/drivers/docker.html)
* [Elastic Docker Images](https://www.docker.elastic.co/#)
* [Elasticsearch Docker Install](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html)
* [Elasticsearch Configuration](https://www.elastic.co/guide/en/elasticsearch/reference/current/settings.html)
* [Kibana Configuration](https://www.elastic.co/guide/en/kibana/current/production.html)
  * [Kibana Configuration Parameter](https://www.elastic.co/guide/en/kibana/current/settings.html) ( Check: `server.basePath` )
* [Elastic Search Configuration via Nomad template](https://groups.google.com/forum/#!topic/nomad-tool/yEd9VLZvE7w) ( It was not fully working. )

Example of running a service with fluentd logging: `logtestapp.nomad`

## TODO
* [] ElasticSearch Persistence 
* [] Kibana UI is accessible

## Notes
### Elasticsearch
"We recommend to use debian version for production because it uses jemalloc to mitigate memory fragmentation issue."

# CI/CD
Giving [Concourse](https://concourse-ci.org/concourse-vs.html) a try.

## References
* [Setup](https://concourse-ci.org/docker-repository.html)
* [Nomad privileged](https://www.nomadproject.io/docs/drivers/docker.html#privileged)
* [Testing](https://concourse-ci.org/hello-world.html)
* [Prometheus Support Discussion](https://github.com/concourse/concourse/issues/1540) ( open )
  * [1st Part](https://github.com/concourse/atc/pull/216)
  * [Alertmanager Resource](https://github.com/frodenas/alertmanager-resource)
* [AWS ECR Support](https://github.com/concourse/docker-image-resource/issues/36)
  * [Credential Helper Support](https://github.com/concourse/docker-image-resource/commit/297e88e800f14cabd42727639bec4cba120395f2)
* [Artifactory](https://github.com/pivotalservices/concourse-pipeline-samples/tree/master/artifactory-integration)
  * [Artifactory Resource](https://github.com/pivotalservices/artifactory-resource)
* [Best Practice](https://github.com/pivotalservices/concourse-pipeline-samples/tree/master/concourse-pipeline-patterns)
  * [Vault](https://github.com/pivotalservices/concourse-pipeline-samples/tree/master/concourse-pipeline-patterns/vault-integration)
    * [Vault Resource](https://github.com/Docurated/concourse-vault-resource)
* [Sonarqube Resource](https://github.com/cathive/concourse-sonarqube-resource)
  * [Sonarqube Task](https://github.com/cathive/concourse-sonarqube-qualitygate-task)
* [Gated Deployment into Production](https://github.com/pivotalservices/concourse-pipeline-samples/tree/master/concourse-pipeline-patterns/gated-pipelines)
* [Parametrized Tasks (Templates)](https://github.com/pivotalservices/concourse-pipeline-samples/tree/master/concourse-pipeline-patterns/parameterized-pipeline-tasks)
* [Single File Tracking with cURL](https://github.com/pivotalservices/concourse-curl-resource)
* [Slack](https://github.com/cloudfoundry-community/slack-notification-resource)
* [GitLab Merge Requests](https://github.com/swisscom/gitlab-merge-request-resource)
* [Passing Key/Values between Jobs](https://github.com/swce/keyval-resource)
* [Ressource Implementation Helper/Template](https://github.com/redfactorlabs/concourse-smuggler-resource)
* [Terraform Concourse Resource](https://github.com/ljfranklin/terraform-resource)
  * Needs `access_key_id` and `+secret_access_key` to be configured.
  * [Example Pipeline](https://github.com/ljfranklin/terraform-resource/blob/master/ci/pipeline.yml)
* [Hashicorp Release Checker](https://github.com/starkandwayne/hashicorp-release-resource)
  * It could be fun to combine this with Slack and get an automated update notifier.

# Issue: Getting around all the different IP-Adress Handling
Everywhere IP addresses are needed, but in a cluster they are not fixed and can change.

## Ideas
* [confd - content of configuration files from consul](https://github.com/kelseyhightower/confd/blob/master/docs/quick-start-guide.md)
  * The current state of all relevant configuration is in Consul.
  * Additional service running taking care of updates an restarts! - not nice.
