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
      config {
        image = "<aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/service/fluentd:2018-04-30_13-19-449c92843_dirty"

        port_map = {
          logstream = 8002
        }

        ulimit {
          nofile = "65536:65536"
        }

        # TODO: attach a persistent volume for indexes
        #volumes = []

        dns_servers = ["${attr.unique.network.ip-address}"] # use local consul to allow own service resolution

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
            static = "8002"
          }
        }
      }

      env {
      }
    }
  }
}
