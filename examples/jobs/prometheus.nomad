# job>group>task>service
# container for tasks or task-groups that nomad should run
job "prometheus" {
  datacenters = ["public-services"]
  type = "service"

  # The group stanza defines a series of tasks that should be co-located on the same Nomad client.
  # Any task within a group will be placed on the same client.
  group "prometheus_group" {
    count = 1

    # restart-policy
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    # The task stanza creates an individual unit of work, such as a Docker container, web application, or batch processing.
    task "prometheus-server" {
      driver = "docker"
      config {
        # AWS ECR playground:
        image = "<aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/service/prometheus:latest"
      }

      config {
        port_map = {
          http = 9090
        }
      }

      resources {
        cpu    = 500 # MHz
        memory = 600 # MB
        network {
          mbits = 10
          port "http" {
          }
        }
      }

      # The service stanza instructs Nomad to register the task as a service using the service discovery integration
      service {
        name = "prometheus"
        tags = ["urlprefix-/prometheus"] # fabio
        port = "http"
        check {
          name     = "Prometheus Alive State"
          port     = "http"
          type     = "http"
          method   = "GET"
          path     = "/prometheus/-/healthy"
          interval = "10s"
          timeout  = "2s"
        }
       }
    }

    task "prom-consul-exporter" {
      driver = "docker"
      config {
        image = "<aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/service/prom-consul-exporter:0.0.1"
        args = [
          "--consul.server=172.17.0.1:8500"
        ]
      }

      config {
        port_map = {
          http = 9107
        }
      }

      resources {
        cpu    = 100 # MHz
        memory = 100 # MB
        network {
          mbits = 10
          port "http" {
          }
        }
      }

      service {
        name = "prom-consul-exporter"
        tags = ["urlprefix-/prom-consul-exporter"] # fabio
        port = "http"
        check {
          name = "Prometheus Consul Exporter Alive Status"
          port = "http"
          type = "http"
          method = "GET"
          path = "/"
          interval = "10s"
          timeout = "2s"
        }
      }
    }
  }
}
