# job>group>task>service
# container for tasks or task-groups that nomad should run
job "ping_service" {
  datacenters = ["public-services","private-services","content-connector"]
  type = "service"

  meta {
    my-key = "example"
  }

  # The group stanza defines a series of tasks that should be co-located on the same Nomad client.
  # Any task within a group will be placed on the same client.
  group "ping_service_group" {
    count = 5

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
        # Docker Hub:
        image = "thobe/ping_service:0.0.7"
        # AWS ECR playground: image = "<aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/service/ping-service:0.0.7"
        #args    = ["Hello, World!"]
      }

      config {
        port_map = {
          http = 8080
        }
      }

      resources {
        cpu    = 500 # MHz
        memory = 128 # MB
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
        SERVICE_NAME        = "${NOMAD_TASK_NAME}",
        PROVIDER            = "ping-service",
        CONSUL_SERVER_ADDR  = "172.17.0.1:8500"
      }
    }
  }
}
