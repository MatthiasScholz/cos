job "fabio" {
  datacenters = ["{{datacenter}}"]

  type = "system"

  update {
    stagger = "5s"
    max_parallel = 1
  }

  group "fabio" {
    task "fabio" {
      driver = "docker"
      config {
        image = "fabiolb/fabio:latest"

        port_map = {
          http = 9999
          ui   = 9998
        }

        volumes = [
          "local/fabio.properties:/etc/fabio/fabio.properties"
        ]
      }

      resources {
        cpu = 500
        memory = 128
        network {
          mbits = 1

          port "http" {
            static = 9999
          }
          port "ui" {
            static = 9998
          }
        }
      }

      template {
        data = <<EOH
registry.consul.addr = {{host_ip_address}}:8500
EOH
        destination = "local/fabio.properties"
        change_mode = "noop"
      }
    }
  }
}
