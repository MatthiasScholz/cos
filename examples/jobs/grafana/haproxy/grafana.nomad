job "grafana" {
  datacenters = ["dc1"]

  type = "service"

  update {
    # Stagger updates every 10 seconds
    stagger = "10s"

    # Update a single task at a time
    max_parallel = 1
  }

  group "grafana" {
    task "haproxy" {
      # Use Docker to run the task.
      driver = "docker"

      # Configure Docker driver with the image
      config {
        image = "library/haproxy:1.8.9-alpine"

        port_map {
          http = 80
        }
      }

      env {
        SUBPATH = "grafana"
        GRAFANAADDR = "NOMAD_ADDR_grafana-ui_http"
      }

      service {
        name = "${TASKGROUP}-service"
        tags = ["global", "grafanahaproxy", "urlprefix-grafana/"]
        port = "http"

        check {
          name     = "alive"
          type     = "http"
          interval = "10s"
          timeout  = "3s"
          path     = "/health"
        }
      }
    }
    task "grafana-ui" {
      driver = "docker"

      config {
        image = "???"

        port_map {
          http = 80
        }
      }
    }
  }
}
