# Overview
Collection of nomad sample jobs.

# Fabio
The examples uses fabio as the cluster internal load balances. This has implications on the security group configuration and the ALB configuration.

* Job Type: system

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
* [Issue](https://github.com/prometheus/prometheus/issues/1583)

### TODOs
* [ ] [Use consul to discover nodes dynamically](https://misterhex.github.io/Prometheus-and-Consul-for-monitoring-dynamic-services/)

## Grafana
Grafana Dashboarding service for metrics as Docker container. Shall visualise COS metrics.

* Job Type: service

### UI
* Default credentials: admin/admin

* [DataSource Configuration](https://prometheus.io/docs/visualization/grafana/#creating-a-prometheus-data-source)
  * [Preconfiguration](http://docs.grafana.org/administration/provisioning/)

* URL: <take_it_from_fabio_ui>
* Access: `proxy`
