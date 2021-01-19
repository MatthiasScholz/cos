job "grafana" {
  datacenters = ["backoffice"]

  type = "service"

  update {
    # Stagger updates every 10 seconds
    stagger = "10s"

    # Update a single task at a time
    max_parallel = 1
  }

  group "grafana" {

    network {
      port "grafana" {
        to = 3000
      }
      port "haproxy" {
        to = 80
      }
    }

    task "ui" {
      driver = "docker"

      config {
        image = "grafana/grafana"
        ports = ["grafana"]

        volumes = [
          "local/datasources.yaml:/etc/grafana/provisioning/datasources/datasources.yaml",
        ]
      }

      resources {
        cpu    = 200 # MHz
        memory = 200 # MB
        }

      env {
        GF_SERVER_DOMAIN = "backoffice.nomadpoc"
        GF_SERVER_ROOT_URL = "http://backoffice.nomadpoc/grafana/"
      }

      template {
        change_mode = "noop"
        destination = "local/datasources.yaml"

        data = <<EOH
# config file version
apiVersion: 1

datasources:
  - name: COS Metrics
    type: prometheus
    access: proxy
    url: http://172.17.0.1:9999/prometheus # Use Fabio to route the requests to prometheus.
    isDefault:
EOH
      }

      service {
        name = "${TASKGROUP}-${TASK}-service"
        tags = ["global", "grafanaui"]
        port = "grafana"

        check {
          name     = "Grafana Alive State"
          type     = "http"
          method   = "GET"
          path     = "/api/health"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }

    task "proxy" {
      # Use Docker to run the task.
      driver = "docker"

      # Configure Docker driver with the image
      config {
        image = "haproxy:2.3.4-alpine"
        ports = ["haproxy"]

        volumes = [
          "local/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg",
        ]
      }

      resources {
        cpu    = 100 # MHz
        memory = 100 # MB
      }

      env {
        SUBPATH = "grafana"
        GRAFANAADDR = "${NOMAD_ADDR_grafana}"
      }

      template {
        change_mode = "noop"
        destination = "local/haproxy.cfg"

        data = <<EOH
defaults
  mode http
  timeout connect 5000ms
  timeout client 50000ms
  timeout server 50000ms

# HTTP response : 'HTTP/1.0 200 OK'
frontend health_status
  http-request return status 200
  bind *:8080
  # This option will lead to a warning
  # "[WARNING] 179/080042 (1) : parsing [/usr/local/etc/haproxy/haproxy.cfg:16] : 'httpchk' ignored because frontend 'health_status' has no backend capability."
  # - BUT Deactivating this option will lead to a none functional health endpoint!
  option httpchk

frontend http-in
  bind *:80
  use_backend grafana_backend if { path /"${SUBPATH}" } or { path_beg /"${SUBPATH}"/ }
  use_backend health_backend if { path /health } or { path_beg /health/ }

backend grafana_backend
  # Requires haproxy >= 1.6
  http-request set-path %[path,regsub(^/"${SUBPATH}"/?,/)]

  server "${SUBPATH}" "${GRAFANAADDR}"

backend health_backend
  server health localhost:8080
EOH
      }

      service {
        name = "${TASKGROUP}-${TASK}-service"
        tags = ["global", "grafanahaproxy", "urlprefix-/grafana"]
        port = "haproxy"

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
