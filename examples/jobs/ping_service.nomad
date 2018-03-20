
# job>group>task>service
# container for tasks or task-groups that nomad should run
job "ping_service" {
  datacenters = ["public-services"]
  type = "service"

  meta {
    my-key = "example"
  }

  # The group stanza defines a series of tasks that should be co-located on the same Nomad client.
  # Any task within a group will be placed on the same client. 
  group "ping_service_group" {
    count = 3

    # restart-policy
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    # The task stanza creates an individual unit of work, such as a Docker container, web application, or batch processing.
    task "ping_service_task" {
      driver = "docker"
      config {
        image = "thobe/ping_service:0.0.7"
      }

      config {
        port_map = {
          http = 8080
        }
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
        network {
          mbits = 10
          port "http" {
          }
        }
      }

      # The service stanza instructs Nomad to register the task as a service using the service discovery integration
      service {
        name = "ping-service"
        tags = ["urlprefix-/ping"]
        port = "http"
        check {
          name     = "alive"
          port     = "http"
          type     = "http"
          method   = "GET"
          path     = "/ping"
          interval = "10s"
          timeout  = "2s"
        }
       }

      env {
        SERVICE_NAME        = "${NOMAD_TASK_NAME}",
        PROVIDER            = "ping-service",
      }
    }
  }
}