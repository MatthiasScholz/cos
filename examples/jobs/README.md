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

## Grafana
Grafana Dashboarding service for metrics as Docker container. Shall visualise COS metrics.

* Job Type: service

### UI
* Default credentials: admin/admin
