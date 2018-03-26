job "logging-fluentd" {
  datacenters = ["public-services"]
  type = "system"

  restart {
    attempts = 10
    interval = "5m"
    delay    = "25s"
    mode     = "delay"
  }

  task "fluentd" {
    driver = "docker"
    config {
      image = "<aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/service/elasticsearch:"
      hostname = "fluentd.local"

      port_map = {
        http = 9880
        forward = 24224
        prom = 24231
      }

      logging {
        type = "json-file"
      }

      volumes = [
        ""
      ]
    }

    resources {
      cpu    = 100 # Mhz
      memory = 300 # MB
      network {
        mbits = 10
        port "http" {}
        port "forward" {}
        port "prom" {}
    }

    service {
      name = "fluentd"
      tags = ["urlprefix-/fluentd"] # fabio
      port = "http"
      check {
        name     = "Fluentd Alive State"
        port     = "http"
        type     = "http"
        method   = "GET"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    env {
      FLUENTD_CONF = "elk.conf"
    }
  }
}
