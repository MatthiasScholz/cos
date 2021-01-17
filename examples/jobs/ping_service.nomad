# job>group>task>service
# container for tasks or task-groups that nomad should run
job "ping_service" {
  datacenters = ["public-services","private-services","content-connector","backoffice"]
  type = "service"

  # The group stanza defines a series of tasks that should be co-located on the same Nomad client.
  # Any task within a group will be placed on the same client.
  group "ping_service_group" {
    count = 4

    # restart-policy
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

     ephemeral_disk {
      migrate = false
      size    = "50"
      sticky  = false
    }

    # The task stanza creates an individual unit of work, such as a Docker container, web application, or batch processing.
    task "ping_service_task" {
      driver = "docker"
      config {
        # Docker Hub:
        image = "thobe/ping_service:0.0.9"
      }

      logs {
        max_files     = 2
        max_file_size = 10
      }

      config {
        port_map = {
          http = 8080
        }
      }

      resources {
        cpu    = 100 # MHz
        memory = 20 # MB
        network {
          mbits = 10
          port "http" {
          }
        }
      }

      # The service stanza instructs Nomad to register the task as a service using the service discovery integration
      service {
        name = "ping-service"
        tags = ["urlprefix-/ping"] # fabio
        port = "http"
        check {
          name     = "Ping-Service Alive State"
          port     = "http"
          type     = "http"
          method   = "GET"
          path     = "/ping"
          interval = "10s"
          timeout  = "2s"
        }
       }

      env {
        SERVICE_NAME        = "${NOMAD_DC}",
        PROVIDER            = "ping-service",
        # uncomment to enable sd over consul
        CONSUL_SERVER_ADDR  = "172.17.0.1:8500"
        #PROVIDER_ADDR = "ping-service:25000"
      }
    }
  }
}
