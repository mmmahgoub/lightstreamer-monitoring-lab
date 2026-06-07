variable "kubeconfig" {
  description = "Path to the kubeconfig file used to connect to Minikube."
  type        = string
  default     = "~/.kube/config"
}
