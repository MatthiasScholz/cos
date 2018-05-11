job "fluentd_sys" {
  datacenters = ["backoffice", "content-connector", "public-services", "private-services"]
  type = "system"

  group "fluentd_group" {
    update {
      stagger = "10s"
      max_parallel = 1
    }

    task "fluentd" {
      driver = "docker"

      env {
        # Vars are used by fluentd.conf.tpl
        LOGGING_ELASTICSEARCH_HOST = "elasticsearch.service.consul"
        LOGGING_ELASTICSEARCH_PORT = "29200"
        LOGGING_FLUENTD_PORT = "8002"
      }

      config {
        image = "<aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/service/fluentd:2018-04-30_18-15-49abec258_dirty"

        port_map = {
          logstream = "${LOGGING_FLUENTD_PORT}"
        }

        ulimit {
          nofile = "65536:65536"
        }

        volumes = [
          "local/fluentd.yml:/fluentd/etc/fluentd.yml"
        ]

        dns_servers = ["${attr.unique.network.ip-address}"] # use local consul to allow own service resolution

        logging {
          type = "json-file" # So logs can be checked with `docker logs`
        }
      }

      artifact {
        source      = "git::https://github.com/serkas/cos/examples/jobs/logging/fluentd/fluent.conf.tpl"
        destination = "local/fluentd.conf.tpl"
        mode        = "file"
      }

      template {
        source        = "local/fluentd.conf.tpl"
        destination   = "local/fluentd.conf"
        change_mode   = "signal"
        change_signal = "SIGINT"
      }

      resources {
        cpu    =  100 # MHz
        memory = 100 # MB
        network {
          mbits = 10
          port "logstream" {
            static = "${LOGGING_FLUENTD_PORT}"
          }
        }
      }
    }
  }
}
