job "fabio" {
  datacenters = ["testing"]

  type = "system"

  update {
    stagger = "5s"
    max_parallel = 1
  }

  group "fabio" {
    network {
      port "http" {
        static = 9999
        to = 9999
      }
      port "ui" {
        static = 9998
        to = 9998
      }
    }

    task "fabio" {
      driver = "docker"
      config {
        image = "fabiolb/fabio:latest"

        ports = [ "http", "ui", "lb" ]

        volumes = [
          "local/fabio.properties:/etc/fabio/fabio.properties"
        ]
      }

      resources {
        cpu = 500
        memory = 128
      }

      template {
        data = <<EOH
registry.consul.addr = <host_ip_address>:8500
EOH
        destination = "local/fabio.properties"
        change_mode = "noop"
      }
    }
  }
}
