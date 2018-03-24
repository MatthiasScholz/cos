job "cicd" {
  datacenters = ["public-services"]
  type = "service"

  group "cicd_group" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "postgres" {
      driver = "docker"
      config {
        image = "<aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/service/postgres:2018-03-24_09-37-08a9be79f_dirty"

        port_map = {
          http = 80
          db   = 5432
        }
      }

      resources {
        cpu    = 500 # MHz
        memory = 500 # MB
        network {
          mbits = 10
          port "http" {}
          port "db"   {}
        }
      }

      service {
        name = "postgres"
        tags = ["urlprefix-/postgres"] # fabio
        port = "http"
        check {
          name     = "Postgres Alive State"
          port     = "http"
          type     = "http"
          method   = "GET"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }

      env {
        POSTGRES_DB       = "concourse"
        POSTGRES_USER     = "concourse"
        POSTGRES_PASSWORD = "changeme"
        PGDATA            = "/database"
      }
    }

    task "concourse-serv" {
      driver = "docker"
      config {
        image = "<aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/service/concourse:2018-03-24_10-21-36_a9be79f_dirty"

        port_map = {
          http  = 8080
          tsa   = 2222
          debug = 8079
        }

        command = "web"
      }

      resources {
        cpu    = 500 # MHz
        memory = 500 # MB
        network {
          mbits = 10
          port "http" {}
          port "tsa"  {}
        }
      }

      service {
        name = "concourse-serv"
        tags = ["urlprefix-/concourse-serv"] # fabio
        port = "http"
        check {
          name     = "Concourse Server Alive State"
          port     = "http"
          type     = "http"
          method   = "GET"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }

      env {
        CONCOURSE_BASIC_AUTH_USERNAME = "concourse"
        CONCOURSE_BASIC_AUTH_PASSWORD = "changeme"
        CONCOURSE_EXTERNAL_URL        = "http://${NOMAD_IP_concourse-serv_http}:${NOMAD_PORT_concourse-serv_http}"
        CONCOURSE_POSTGRES_HOST       = "${NOMAD_IP_postgres_db}"
        CONCOURSE_POSTGRES_PORT       = "${NOMAD_PORT_postgres_db}"
        CONCOURSE_POSTGRES_USER       = "concourse"
        CONCOURSE_POSTGRES_PASSWORD   = "changeme"
        CONCOURSE_POSTGRES_DATABASE   = "concourse"
      }

    }

    task "concourse-work" {
      driver = "docker"
      config {
        image = "<aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/service/concourse:2018-03-24_10-21-36_a9be79f_dirty"

        # DISABLED port_map = {
        # DISABLED   http = 0
        # DISABLED }

        command    = "worker"
        privileged = true
      }

      resources {
        cpu    = 500 # MHz
        memory = 500 # MB
        network {
          mbits = 10
          # DISABLED port "http" {}
        }
      }

      # DISABLED service {
      # DISABLED   name = "concourse-work"
      # DISABLED   tags = ["urlprefix-/concourse-work"] # fabio
      # DISABLED   port = "http"
      # DISABLED   check {
      # DISABLED     name     = "concourse-work Alive State"
      # DISABLED     port     = "http"
      # DISABLED     type     = "http"
      # DISABLED     method   = "GET"
      # DISABLED     path     = "/"
      # DISABLED     interval = "10s"
      # DISABLED     timeout  = "2s"
      # DISABLED   }
      # DISABLED }

      env {
        CONCOURSE_TSA_HOST = "${NOMAD_IP_concourse-serv_http}"
        CONCOURSE_TSA_PORT = "${NOMAD_PORT_concourse-serv_tsa}"
      }
    }
  }
}
