# FIXME: Not sure if this setup is working. Currently the COS does not provide support for Consul DNS. DNS should be avoided as much as possible. Hence it is not going to be added as a "feature".
job "logging" {
  datacenters = ["backoffice"]
  type = "service"

  group "logging_group" {
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
        image = "<aws_account_id>.dkr.ecr.eu-central-1.amazonaws.com/service/elasticsearch:2018-05-11_15-31-52d3d2634_dirty"

        port_map = {
          http = 9200
          node = 9300
        }

        ulimit {
          nofile = "65536:65536"
        }

        # TODO: attach a persistent volume for indexes
        volumes = [
          "local/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml"
        ]
      }

      resources {
        cpu    =  300 # MHz
        memory = 500 # MB
        network {
          mbits = 10
          port "http" {
            static = "29200"
          }
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
        # FIXME: Using values near the memory limit did not work.
        #        OOS killed the container because the memory limit was reached.
        #        Might be a bug in Java.
        ES_JAVA_OPTS = "-Xmx256m -Xms256m"
      }

      template {
        data = <<EOH
cluster.name: "es-logging-cluster"
network.host: 0.0.0.0

discovery.zen.minimum_master_nodes: 1
action.auto_create_index: true

EOH
        destination = "local/elasticsearch.yml"
        change_mode = "noop"
      }
    }

    task "kibana" {
      driver = "docker"
      config {
        image = "<aws_account_id>.dkr.ecr.eu-central-1.amazonaws.com/service/kibana:2018-05-11_15-32-18d3d2634_dirty"
        port_map = {
          http = 5601
        }

        volumes = [
          "local/kibana.yml:/usr/share/kibana/config/kibana.yml"
        ]
      }

      resources {
        cpu    =  200 # MHz
        memory = 300 # MB
        network {
          mbits = 10
          port "http" {}
        }
      }

      service {
        name = "kibana"
        tags = ["urlprefix-/app/kibana"] # Fabio
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

elasticsearch.url: "http://elasticsearch.service.consul:{{ env "NOMAD_PORT_elasticsearch_http" }}/"

EOH
        destination = "local/kibana.yml"
        change_mode = "noop"
      }
    }
  }
}
