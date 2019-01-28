job "dsf" {
  datacenters = ["backoffice"]
  type = "service"

  group "dsf_group" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    ephemeral_disk {
      migrate = true
      size    = "500" # MB
      sticky  = true
    }

    task "jupyter" {
      driver = "docker"

      config {
        image = "{{docker_registry_url}}/support/dsf:latest"
        port_map = {
          http = 8888
        }

        volumes = [
          "/tmp/notebooks/:/opt/notebooks/"
        ]
      }

      resources {
        cpu    = 200 # MHz
        memory = 512 # MB
        network {
          mbits = 10
          port "http" {}
        }
      }

      service {
        name = "dsf"
        tags = ["urlprefix-/dsf"] # Fabio
        port = "http"
        check {
          name     = "Jupyter Alive State"
          port     = "http"
          type     = "http"
          method   = "GET"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }

      # DISABLED env {
      # DISABLED   = ""
      # DISABLED }
    }
  }
}
