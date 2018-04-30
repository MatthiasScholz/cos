# Test instance to simulate log messages stream
# Also the container contains some network tools: dig, nslookup, curl
job "logtestapp" {
  datacenters = ["content-connector"]
  type = "service"

  group "logtestapp_group" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "logtestapp" {
      driver = "docker"
      config {
        image = "<aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/service/logtestapp:2018-04-30_16-34-589c92843_dirty"

        ulimit {
          nofile = "65536:65536"
        }

        logging {
          type = "fluentd"
          config {
            fluentd-address = "${attr.unique.network.ip-address}:8002"
            tag = "service.bash.content"
          }
        }
      }

      resources {
        cpu    =  100 # MHz
        memory = 200 # MB
      }
    }
  }
}
