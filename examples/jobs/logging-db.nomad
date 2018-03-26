job "logging-db" {
  datacenters = ["public-services"]
  type = "service"

  group "logging-db_group" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "elasticsearch" {
      driver = "docker"
      config {
        image = "<aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/service/elasticsearch:2018-03-23_14-24-43c9c450b_dirty"

        port_map = {
          http = 9200
          node = 9300
        }

        ulimit {
          nofile = "65536:65536"
        }

        volumes = [
          "local/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml"
        ]
      }

      resources {
        cpu    =  800 # MHz
        memory = 1100 # MB
        network {
          mbits = 10
          port "http" {}
          port "node" {}
        }
      }

      service {
        name = "elasticsearch"
        tags = ["urlprefix-/elasticsearch"] # fabio
        port = "http"
        check {
          name     = "Elasticsearch Alive State"
          port     = "http"
          type     = "http"
          method   = "GET"
          path     = "/_cluster/health"
          interval = "10s"
          timeout  = "2s"
        }
      }

      env {
        ES_JAVA_OPTS          = "-Xmx256m -Xms256m"
      }

      template {
        data = <<EOH
cluster.name: "es-logging-cluster"
network.host: 0.0.0.0

discovery.zen.minimum_master_nodes: 1

action.auto_create_index: filebeat*

EOH
        destination = "local/elasticsearch.yml"
        change_mode = "noop"
      }
    }
  }
}
