job "logging-ui" {
  datacenters = ["public-services"]
  type = "service"

  group "logging-ui_group" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "kibana" {
      driver = "docker"
      config {
        image = "<aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/service/kibana:2018-03-23_14-20-25c9c450b_dirty"
        port_map = {
          http = 5601
        }

        volumes = [
          "local/kibana.yml:/usr/share/kibana/config/kibana.yml"
        ]
      }

      resources {
        cpu    =  800 # MHz
        memory = 1100 # MB
        network {
          mbits = 10
          port "http" {}
        }
      }

      service {
        name = "kibana"
        tags = ["urlprefix-/kibana"] # Fabio
        port = "http"
        check {
          name = "Kibana Alive State"
          port = "http"
          type = "http"
          method = "GET"
          path = "/api/status"
          interval = "10s"
          timeout = "2s"
        }
      }

      template {
        data = <<EOH
server.name: logging-cluster-ui
server.host: "0"
# FIXME: Ugly HACK!!! - first work around would be to put job definition in one file.
elasticsearch.url: "http://10.128.26.103:26311/"

EOH
        destination = "local/kibana.yml"
        change_mode = "noop"
      }
    }
  }
}
