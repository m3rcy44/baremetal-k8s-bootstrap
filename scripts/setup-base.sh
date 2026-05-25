#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "Step 1/6: Creating Lima VMs..."
./scripts/create-vms.sh

echo
echo "Step 2/6: Generating Ansible inventory..."
./scripts/generate-inventory.sh

echo
echo "Step 3/6: Checking Ansible connectivity..."
./scripts/bootstrap.sh

echo
echo "Step 4/6: Preparing Linux hosts..."
./scripts/prepare-linux.sh

echo
echo "Step 5/6: Installing containerd..."
./scripts/install-containerd.sh

echo
echo "Step 6/6: Installing Kubernetes tools..."
./scripts/install-kubernetes-tools.sh

echo
echo "Base setup completed."
echo "Next step: run ./scripts/init-cluster.sh and ./scripts/install-flannel.sh"
