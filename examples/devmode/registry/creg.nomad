job "creg" {
  datacenters = [ "{{datacenter}}" ]
  type = "service"

  update {
    auto_revert = true
    max_parallel = 1
  }

  group "server" {
    count = 1

    task "registry" {
      driver = "docker"

      config {
        image = "registry:2"

        port_map = {
          http = 5000
        }
      }

      service {
        port = "http"
      }

      resources {
        cpu    = "128" # MHz
        memory = "128" # MB

        network {
          mbits = 10

          port "http" {
            static = 5000
          }
        }
      }
    }
  }
}
