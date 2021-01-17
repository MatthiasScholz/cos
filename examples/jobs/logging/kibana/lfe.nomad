job "lfe" {
  datacenters = ["testing"]
  type = "service"

  group "lfe_group" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    # NOTE: Add HAProxy configuration is NOT needed!
    #       Kibana already does the trick with the options:
    #       . SERVER_BASEPATH
    #       . SERVER_REWRITEBASEPATH

    task "kibana" {
      driver = "docker"
      config {
        image = "docker.elastic.co/kibana/kibana-oss:6.5.4"
        port_map = {
          http = 5601
        }
      }

      resources {
        cpu    = 200 # MHz
        memory = 300 # MB
        network {
          mbits = 10
          port "http" {}
        }
      }

      service {
        name = "lfe"
        tags = ["urlprefix-/lfe"] # Fabio
        port = "http"
        check {
          name     = "Logging Frontend Alive State"
          port     = "http"
          type     = "http"
          method   = "GET"
          path     = "/lfe/api/status"
          interval = "10s"
          timeout  = "2s"
        }
      }

      # SEE: www.elastic.co/guide/en/kibana/current/settings.html
      env {
        SERVER_NAME            = "logging-frontend"
        SERVER_BASEPATH        = "/lfe"
        SERVER_REWRITEBASEPATH = "true"
        # NOTE: TESTING:
        #       Only for local setups where everything is running on one machine
        #       Furthermore that the port mentioned here matches the one configured in: lds.nomad.
        ELASTICSEARCH_URL      = "http://${attr.unique.network.ip-address}:29200/"
      }
    }
  }
}
