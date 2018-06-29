job "grafana" {
  datacenters = ["public-services"]

  type = "service"

  update {
    # Stagger updates every 10 seconds
    stagger = "10s"

    # Update a single task at a time
    max_parallel = 1
  }

  group "grafana" {

    task "grafana-ui" {
      driver = "docker"

      config {
        image = "<aws_account_id>.dkr.ecr.eu-central-1.amazonaws.com/service/grafana:2018-06-29_11-15-06_7ef8eb5_dirty"

        port_map {
          http = 3000
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

      env {
        GF_SERVER_DOMAIN = "backoffice.nomadpoc"
        GF_SERVER_ROOT_URL = "http://backoffice.nomadpoc/grafana/"
      }

      service {
        name = "${TASKGROUP}-${TASK}-service"
        tags = ["global", "grafanaui"]
        port = "http"

        check {
          name     = "Grafana Alive State"
          port     = "http"
          type     = "http"
          method   = "GET"
          path     = "/api/health"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }

    task "haproxy" {
      # Use Docker to run the task.
      driver = "docker"

      # Configure Docker driver with the image
      config {
        image = "<aws_account_id>.dkr.ecr.eu-central-1.amazonaws.com/service/grafanahaproxy:2018-06-29_10-05-39_ea68d7c_dirty"

        port_map {
          http = 80
        }
      }

      resources {
        cpu    = 100 # MHz
        memory = 100 # MB
        network {
          mbits = 10
          port "http" {}
        }
      }

      env {
        SUBPATH = "grafana"
        GRAFANAADDR = "${NOMAD_ADDR_grafana-ui_http}"
      }

      service {
        name = "${TASKGROUP}-${TASK}-service"
        tags = ["global", "grafanahaproxy", "urlprefix-/grafana"]
        port = "http"

        check {
          name     = "HAProxy Alive State"
          type     = "http"
          interval = "10s"
          timeout  = "3s"
          path     = "/health"
        }
      }
    }
  }
}
