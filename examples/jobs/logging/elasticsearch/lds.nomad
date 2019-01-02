job "lds" {
  datacenters = ["testing"]
  type = "service"

  group "lds_group" {
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
        image = "docker.elastic.co/elasticsearch/elasticsearch-oss:6.5.4"
        # Option2:
        # For local Docker image builds - check NOTE section below.
        # image = "<host_ip_address>:5000/support/logging/lds:latest"


        port_map = {
          http = 9200
          node = 9300
        }

        ulimit {
          nofile = "65536:65536"
        }
      }

      resources {
        cpu    =  300 # MHz
        memory = 1024 # MB
        network {
          mbits = 10
          port "http" {
            static = "29200"
          }
          port "node" {}
        }
      }

      service {
        name = "lds"
        tags = ["urlprefix-/lds"] # fabio
        port = "http"
        check {
          name     = "Logging Data Store Alive State"
          port     = "http"
          type     = "http"
          method   = "GET"
          path     = "/_cluster/health"
          interval = "10s"
          timeout  = "2s"
        }
      }

      # NOTE: It might look a bit weird to use environment variables here and then to add them in the template section. This is done to show two possibilities to configure Elasticsearch:
      # 1. Creating a custom Docker image which the "elasticsearch.yml" baked in and configure it using the "env" section
      # 2. Using the template functionality of Nomad to inject a customized configuration
      # Suggestion: For this specific setup it might be better to avoid the additional Docker volume mount and just provide an Elasticsearch configuration using environment variables. For local testing without the need of a local Docker registry the mounting could be still convenient.
      env {
        # FIXME: Using values near the memory limit did not work.
        #        OOS killed the container because the memory limit was reached.
        #        Might be a bug in Java.
        ES_JAVA_OPTS = "-Xmx256m -Xms256m"
        CLUSTER_NAME = "es-logging-cluster"
        NETWORK_HOST = "0.0.0.0"
        DISCOVERY_ZEN_MINIMUM_MASTER_NODES = "1"
        ACTION_AUTO_CREATE_INDEX = "true"
      }

      template {
        data = <<EOH
cluster.name: ${CLUSTER_NAME}
network.host: ${NETWORK_HOST}

# minimum_master_nodes need to be explicitly set when bound on a public IP
# set to 1 to allow single node clusters
# Details: https://github.com/elastic/elasticsearch/pull/17288
discovery.zen.minimum_master_nodes: ${DISCOVERY_ZEN_MINIMUM_MASTER_NODES}

action.auto_create_index: ${ACTION_AUTO_CREATE_INDEX}
EOH
        destination = "local/elasticsearch.yml"
        change_mode = "noop"
      }
    }
  }
}
