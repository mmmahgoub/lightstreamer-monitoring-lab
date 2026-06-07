output "lightstreamer_url" {
  value       = "http://<minikube-ip>:30080"
  description = "URL for accessing the Lightstreamer service via NodePort."
}

output "prometheus_url" {
  value       = "http://<minikube-ip>:30090"
  description = "URL for accessing the Prometheus service via NodePort."
}

output "grafana_url" {
  value       = "http://<minikube-ip>:30030"
  description = "URL for accessing the Grafana service via NodePort."
}
