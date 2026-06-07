#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

command -v kubectl >/dev/null 2>&1 || { echo "kubectl is required. Install kubectl and try again." >&2; exit 1; }

echo "Deleting Kubernetes resources..."
kubectl delete -k k8s/ --ignore-not-found

echo "Cleanup complete."
echo "If you started a repository mount, stop it manually in the terminal where it is running."
