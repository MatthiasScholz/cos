job "fabio" {
  datacenters = ["public-services"]

  type = "system"
  update {
    stagger = "5s"
    max_parallel = 1
  }
  group "fabio" {
    task "fabio" {
      driver = "exec" # Linux only!
      config {
        command = "fabio-1.5.15-go1.15.5-linux_amd64"
      }

      artifact {
        source = "https://github.com/fabiolb/fabio/releases/download/v1.5.15/fabio-1.5.15-go1.15.5-linux_amd64"
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
    }
  }
}
