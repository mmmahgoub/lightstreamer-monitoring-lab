terraform {
  required_version = ">= 1.3.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig
}

resource "kubernetes_service" "lightstreamer" {
  metadata {
    name = "lightstreamer"
  }

  spec {
    selector = {
      app = "lightstreamer"
    }

    type = "NodePort"

    port {
      name       = "http"
      port       = 8080
      target_port = 8080
      node_port  = 30080
    }

    port {
      name       = "exporter"
      port       = 9100
      target_port = 9100
      node_port  = 31010
    }
  }
}

resource "kubernetes_deployment" "lightstreamer" {
  metadata {
    name = "lightstreamer"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "lightstreamer"
      }
    }

    template {
      metadata {
        labels = {
          app = "lightstreamer"
        }
      }

      spec {
        container {
          name  = "lightstreamer"
          image = "lightstreamer:latest"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 8080
          }

          port {
            container_port = 9100
          }

          volume_mount {
            name       = "adapter-volume"
            mount_path = "/lightstreamer/adapters/metrics_exporter"
          }
        }

        volume {
          name = "adapter-volume"

          host_path {
            path = "/mnt/repo/adapters/metrics_exporter"
            type = "Directory"
          }
        }
      }
    }
  }
}

resource "kubernetes_config_map" "prometheus_config" {
  metadata {
    name = "prometheus-config"
  }

  data = {
    "prometheus.yml" = <<-EOF
      global:
        scrape_interval: 5s

      scrape_configs:
        - job_name: 'lightstreamer'
          static_configs:
            - targets: ['lightstreamer:9100']
    EOF
  }
}

resource "kubernetes_service" "prometheus" {
  metadata {
    name = "prometheus"
  }

  spec {
    selector = {
      app = "prometheus"
    }

    type = "NodePort"

    port {
      name       = "web"
      port       = 9090
      target_port = 9090
      node_port  = 30090
    }
  }
}

resource "kubernetes_deployment" "prometheus" {
  metadata {
    name = "prometheus"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "prometheus"
      }
    }

    template {
      metadata {
        labels = {
          app = "prometheus"
        }
      }

      spec {
        container {
          name  = "prometheus"
          image = "prom/prometheus:latest"

          args = [
            "--config.file=/etc/prometheus/prometheus.yml"
          ]

          port {
            container_port = 9090
          }

          volume_mount {
            name       = "prometheus-config"
            mount_path = "/etc/prometheus/prometheus.yml"
            sub_path   = "prometheus.yml"
          }
        }

        volume {
          name = "prometheus-config"

          config_map {
            name = kubernetes_config_map.prometheus_config.metadata[0].name

            items {
              key  = "prometheus.yml"
              path = "prometheus.yml"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "grafana" {
  metadata {
    name = "grafana"
  }

  spec {
    selector = {
      app = "grafana"
    }

    type = "NodePort"

    port {
      name       = "web"
      port       = 3000
      target_port = 3000
      node_port  = 30030
    }
  }
}

resource "kubernetes_deployment" "grafana" {
  metadata {
    name = "grafana"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "grafana"
      }
    }

    template {
      metadata {
        labels = {
          app = "grafana"
        }
      }

      spec {
        container {
          name  = "grafana"
          image = "grafana/grafana:latest"

          env {
            name  = "GF_SECURITY_ADMIN_PASSWORD"
            value = "admin"
          }

          env {
            name  = "GF_AUTH_ANONYMOUS_ENABLED"
            value = "true"
          }

          env {
            name  = "GF_AUTH_ANONYMOUS_ORG_ROLE"
            value = "Admin"
          }

          port {
            container_port = 3000
          }

          volume_mount {
            name       = "grafana-provisioning"
            mount_path = "/etc/grafana/provisioning"
          }

          volume_mount {
            name       = "grafana-dashboards"
            mount_path = "/var/lib/grafana/dashboards"
          }
        }

        volume {
          name = "grafana-provisioning"

          host_path {
            path = "/mnt/repo/grafana/provisioning"
            type = "Directory"
          }
        }

        volume {
          name = "grafana-dashboards"

          host_path {
            path = "/mnt/repo/grafana/dashboards"
            type = "Directory"
          }
        }
      }
    }
  }
}
