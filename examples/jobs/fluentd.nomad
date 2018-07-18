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
        # Vars are used by fluentd.conf
        LOGGING_ELASTICSEARCH_HOST = "elasticsearch.service.consul"
        LOGGING_ELASTICSEARCH_PORT = "80"
        LOGGING_FLUENTD_PORT = "8002"
      }

      config {
        image = "<aws_account_id>.dkr.ecr.eu-central-1.amazonaws.com/service/fluentd:2018-05-11_14-58-55d3d2634_dirty"

        port_map = {
          logstream = "${LOGGING_FLUENTD_PORT}"
        }

        ulimit {
          nofile = "65536:65536"
        }

        dns_servers = ["${attr.unique.network.ip-address}"] # use local (nomad-client) consul to allow service resolution

        logging {
          type = "json-file" # So logs can be checked with `docker logs`
        }
      }

      resources {
        cpu    =  100 # MHz
        memory = 100 # MB
        network {
          mbits = 10
          port "logstream" {
            static = 8002 # int value of LOGGING_FLUENTD_PORT 
          }
        }
      }
    }
  }
}
