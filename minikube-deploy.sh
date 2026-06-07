#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

MOUNT_REPO=false
for arg in "$@"; do
  case "$arg" in
    --mount)
      MOUNT_REPO=true
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

command -v minikube >/dev/null 2>&1 || { echo "minikube is required. Install minikube and try again." >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "kubectl is required. Install kubectl and try again." >&2; exit 1; }

if ! minikube status >/dev/null 2>&1; then
  echo "Starting Minikube..."
  minikube start
else
  echo "Minikube is already running."
fi

echo "Loading Lightstreamer image into Minikube..."
minikube image load lightstreamer:latest

echo "Applying Kubernetes manifests..."
kubectl apply -k k8s/

echo ""
echo "Deployment complete."
if [ "$MOUNT_REPO" = true ]; then
  echo "Starting repository mount in the background..."
  nohup minikube mount "$ROOT":/mnt/repo >/tmp/minikube-mount.log 2>&1 &
  echo "Repository mount started in the background."
  echo "Log: /tmp/minikube-mount.log"
else
  echo "Next, mount the repository into Minikube in another terminal:"
  echo "  cd \"$ROOT\""
  echo "  minikube mount \"$ROOT\":/mnt/repo"
  echo ""
  echo "Or start the mount in the background:"
  echo "  nohup minikube mount \"$ROOT\":/mnt/repo >/tmp/minikube-mount.log 2>&1 &"
  echo ""
fi

echo "Service URLs:"
if ! minikube service grafana --url; then
  MINIKUBE_IP="$(minikube ip)"
  GRAFANA_PORT="$(kubectl get svc grafana -o jsonpath='{.spec.ports[0].nodePort}')"
  echo "Grafana fallback URL: http://$MINIKUBE_IP:$GRAFANA_PORT"
fi
if ! minikube service prometheus --url; then
  MINIKUBE_IP="$(minikube ip)"
  PROM_PORT="$(kubectl get svc prometheus -o jsonpath='{.spec.ports[0].nodePort}')"
  echo "Prometheus fallback URL: http://$MINIKUBE_IP:$PROM_PORT"
fi
if ! minikube service lightstreamer --url; then
  MINIKUBE_IP="$(minikube ip)"
  LS_PORT="$(kubectl get svc lightstreamer -o jsonpath='{.spec.ports[0].nodePort}')"
  echo "Lightstreamer fallback URL: http://$MINIKUBE_IP:$LS_PORT"
fi
