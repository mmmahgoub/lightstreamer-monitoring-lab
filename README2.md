# Lightstreamer Monitoring Lab

This repository contains a local development and testing environment for Lightstreamer, monitored by Prometheus and visualized via Grafana. The infrastructure can be deployed natively using Kubernetes manifests via Minikube or managed programmatically through Terraform.

##  Architecture & Requirements

To prevent configuration drifting and container rollout failures, ensure the following local configurations are established:
1. **Minikube Mount**: The cluster mounts the host project directory to `/mnt/repo` to share metrics adapters and Grafana provisioning dashboards.
2. **Directory Permissions**: Host directories require open write permissions (`777`) so non-root container applications (like Grafana, UID `472`) can write application states.
3. **Internal Docker Daemon**: Local images (like `lightstreamer:latest`) must be built directly inside Minikube's Docker environment.

---

##  Quick Start (Shell Script Deployment)

The shell scripts automate the provisioning, but require a strict order of operations to prevent `SVC_UNREACHABLE` errors.

### Step 1: Fix Host Folder Permissions
Before starting, ensure Grafana and the adapters can read/write to your shared filesystem:
```bash
chmod -R 777 grafana/dashboards grafana/provisioning adapters/metrics_exporter
```

### Step 2: Establish the Storage Bridge First
Open a **dedicated terminal window** and run the mount command. **Leave this terminal running in the background**:
```bash
minikube mount "\$(pwd)":/mnt/repo
```

### Step 3: Build the Local Image inside Minikube
Point your local terminal shell to Minikube's internal Docker registry and build your image:
```bash
eval \$(minikube docker-env)
# Run your docker build command here if you are using a local Dockerfile
# docker build -t lightstreamer:latest .
```

### Step 4: Deploy the Applications
In your main terminal window, run the automated deployment script:
```bash
./minikube-deploy.sh
```

---

##  Terraform Infrastructure Management

If you prefer using Terraform to manage the lifecycle of your local cluster, follow these steps to avoid `Unexpected Identity Change` or duplicate resource errors.

### 1. Verification of Safe State Block Layout
Ensure your `main.tf` leverages the modern `_v1` schemas to completely circumvent provider identity tracking bugs:
* **Service Tracking**: Managed via `resource "kubernetes_service_v1" "lightstreamer"`
* **Deployment Tracking**: Managed via `resource "kubernetes_deployment_v1" "lightstreamer"`

### 2. Standard Deployment Workflow
Always follow this workflow to save logs cleanly and deploy:

```bash
# 1. Initialize the provider plugins
terraform init -reconfigure

# 2. Review and generate a binary execution plan file
terraform plan -out=deploy.tfplan

# 3. Apply the plan and stream terminal logs to an output text document
terraform apply deploy.tfplan | tee terraform_apply_output.txt
```

---

##  Troubleshooting & Cluster Recovery

### Error: `Unexpected Identity Change` or `deployments.apps ... already exists`
This happens if your local Terraform state gets desynchronized from the actual living state inside the Minikube cluster. Use this sequence to hard-reset the tracking layer:

```bash
# 1. Purge legacy resource blocks out of the local state file
terraform state rm kubernetes_deployment.lightstreamer --ignore-not-found=true
terraform state rm kubernetes_deployment_v1.lightstreamer --ignore-not-found=true
terraform state rm kubernetes_deployment.grafana --ignore-not-found=true

# 2. Clean out old cluster deployments to prevent conflicts
kubectl delete deployment lightstreamer -n default --ignore-not-found=true
kubectl delete deployment grafana -n default --ignore-not-found=true

# 3. Re-run deployment completely fresh
terraform apply -auto-approve
```

### Checking Real-Time Pod States
If a deployment hangs during creation, check the cluster logs in a separate window:
```bash
# Monitor deployment status transitions
kubectl get pods -n default -w

# Inspect container startup events for volume issues
kubectl describe pod -l app=grafana

# Inspect application layer crashes
kubectl logs -l app=lightstreamer --tail=50
```
