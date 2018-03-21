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


## Grafana
Grafana Dashboarding service for metrics as Docker container. Shall visualise COS metrics.

* Job Type: service

### UI
* Default credentials: admin/admin

* [DataSource Configuration](https://prometheus.io/docs/visualization/grafana/#creating-a-prometheus-data-source)
  * [Preconfiguration](http://docs.grafana.org/administration/provisioning/)

* URL: <take_it_from_fabio_ui>
* Access: `proxy`
