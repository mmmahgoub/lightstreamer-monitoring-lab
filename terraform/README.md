# Terraform deploy for Minikube

This Terraform configuration deploys the Lightstreamer, Prometheus, and Grafana Kubernetes manifests to a Minikube cluster.

## Requirements

- Minikube running
- `kubectl` configured for Minikube
- `terraform` installed
- Local `lightstreamer:latest` image loaded into Minikube, or update the image name

## Usage

1. Start Minikube and mount the repository:

   minikube start
   minikube mount "$(pwd)":/mnt/repo

2. Initialize Terraform:

   cd terraform
   terraform init

3. Apply the deployment:

   terraform apply

4. Access services:

   minikube ip
   http://<minikube-ip>:30080   # Lightstreamer
   http://<minikube-ip>:30090   # Prometheus
   http://<minikube-ip>:30030   # Grafana

## Notes

- The Terraform deployment relies on the same `hostPath` mounts used by the existing Minikube manifests.
- If you change the repo location, update the `hostPath` values in `terraform/main.tf`.
- If your `kubeconfig` is not `~/.kube/config`, pass it with `-var="kubeconfig=/path/to/config"`.
