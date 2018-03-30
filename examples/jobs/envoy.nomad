job "envoy" {
  datacenters = ["public-services"]
  type = "system"

  group "envoy_group" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "envoy_task" {
      driver = "docker"
      config {
        image = "<aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/service/envoy:2018-03-30_21-11-06_42d60ff_dirty"

        port_map = {
          http = 9901
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

      service {
        name = "envoy"
        tags = ["urlprefix-/envoy"] # fabio
        port = "http"
        check {
          name     = "Envoy Alive State"
          port     = "http"
          type     = "http"
          method   = "GET"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }

      env {
        XDS_IP="${NOMAD_IP_envoy-eds_http}"
        XDS_PORT="${NOMAD_PORT_envoy-eds_http}"
        SERVICE_PORT=25000
      }
    }

      task "envoy-eds" {
        driver = "docker"
        config {
          image = "<aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/service/envoy:2018-03-30_21-11-06_42d60ff_dirty"

          port_map = {
            http = 8053
          }

          command = "/bin/consul-envoy-xds"
        }

        resources {
          cpu    = 100 # MHz
          memory = 100 # MB
          network {
            mbits = 10
            port "http" {}
          }
        }

        service {
          name = "envoy-eds"
          tags = ["urlprefix-/envoy-eds"] # fabio
          port = "http"
          check {
            name     = "Envoy EDS Alive State"
            port     = "http"
            type     = "http"
            method   = "GET"
            path     = "/"
            interval = "10s"
            timeout  = "2s"
          }
        }

        env {
          PORT               = 8053
          LOG_LEVEL          = "INFO"
          CONSUL_CLIENT_PORT = 8500
          CONSUL_CLIENT_HOST = "172.17.0.1"
          CONSUL_DC          = "us-east-1"
          CONSUL_TOKEN       = "unused"
          WATCHED_SERVICE    = "ping-service"
        }
      }
  }
}
