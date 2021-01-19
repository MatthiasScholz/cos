job "prometheus" {
  datacenters = ["backoffice"]
  type        = "service"

  group "monitoring" {
    count = 1

    network {
      port "prometheus" {
        to = 9090
      }
    }

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    ephemeral_disk {
      size = 300
    }

    task "prometheus" {
      template {
        change_mode = "noop"
        destination = "local/prometheus.yml"

        data = <<EOH
---
global:
  scrape_interval:     5s
  evaluation_interval: 5s

scrape_configs:

  - job_name: 'nomad_metrics'

    consul_sd_configs:
    - server: '{{ env "NOMAD_IP_prometheus" }}:8500'
      services: ['nomad-client', 'nomad']

    relabel_configs:
    - source_labels: ['__meta_consul_tags']
      regex: '(.*)http(.*)'
      action: keep

    scrape_interval: 5s
    metrics_path: /v1/metrics
    params:
      format: ['prometheus']
EOH
      }

      driver = "docker"

      config {
        image = "prom/prometheus:latest"
        args  = [ "--config.file=/etc/prometheus/prometheus.yml",
          "--storage.tsdb.path=/prometheus",
          "--web.console.libraries=/usr/share/prometheus/console_libraries",
          "--web.console.templates=/usr/share/prometheus/consoles",
          "--web.external-url=/prometheus/" ]
        volumes = [
          "local/prometheus.yml:/etc/prometheus/prometheus.yml",
        ]
        ports = ["prometheus"]
      }

      service {
        name = "prometheus"
        tags = ["urlprefix-/prometheus"]
        port = "prometheus"

        check {
          name     = "prometheus port alive"
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
