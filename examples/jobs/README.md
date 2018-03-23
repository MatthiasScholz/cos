# Overview
Collection of nomad sample jobs.

# Nomad

## Troubleshooting
When the web ui or the remote query might not show any error logs try ssh into the instance and use the command line tool to examine log messages:
* `nomad logs -stderr <alloc-id>`

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
* [Elastic Docker Images](https://www.docker.elastic.co/#)
* [Elasticsearch Docker Install](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html)
* [Elasticsearch Configuration](https://www.elastic.co/guide/en/elasticsearch/reference/current/settings.html)
* [Kibana Configuration](https://www.elastic.co/guide/en/kibana/current/production.html)
  * [Kibana Configuration Parameter](https://www.elastic.co/guide/en/kibana/current/settings.html) ( Check: `server.basePath` )
* [Elastic Search Configuration via Nomad template](https://groups.google.com/forum/#!topic/nomad-tool/yEd9VLZvE7w) ( It was not fully working. )

## Notes
"We recommend to use debian version for production because it uses jemalloc to mitigate memory fragmentation issue."
