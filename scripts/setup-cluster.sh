#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "Step 1/7: Running base setup..."
./scripts/setup-base.sh

echo
echo "Step 2/7: Initializing Kubernetes cluster..."
./scripts/init-cluster.sh

echo
echo "Step 3/7: Installing Flannel CNI..."
./scripts/install-flannel.sh

echo
echo "Step 4/7: Installing MetalLB..."
./scripts/install-metallb.sh

echo
echo "Step 5/7: Installing ingress-nginx..."
./scripts/install-ingress-nginx.sh

echo
echo "Step 6/7: Deploying demo app..."
./scripts/deploy-demo-app.sh

echo
echo "Step 7/7: Installing monitoring stack..."
./scripts/install-monitoring.sh

echo
echo "Cluster setup completed."
