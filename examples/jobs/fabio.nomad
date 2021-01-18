job "fabio" {
  datacenters = ["public-services", "backoffice"]

  type = "system"
  update {
    stagger = "5s"
    max_parallel = 1
  }
  group "fabio" {
    network {
      port "http" {
        static = 9999
      }
      port "ui" {
        static = 9998
      }
    }

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
      }
    }
  }
}
