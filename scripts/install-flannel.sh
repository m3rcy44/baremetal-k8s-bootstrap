#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
export ANSIBLE_CONFIG="${ROOT_DIR}/ansible/ansible.cfg"

if [ ! -f ansible/inventory/hosts.ini ]; then
  echo "Error: ansible/inventory/hosts.ini not found." >&2
  echo "Run: ./scripts/generate-inventory.sh" >&2
  exit 1
fi

echo "Installing Flannel CNI..."
ansible-playbook ansible/site.yml --tags flannel

echo
echo "Checking Kubernetes nodes..."
ansible masters --become -m command -a "kubectl --kubeconfig=/etc/kubernetes/admin.conf get nodes -o wide"

echo
echo "Checking Flannel pods..."
ansible masters --become -m command -a "kubectl --kubeconfig=/etc/kubernetes/admin.conf get pods -n kube-flannel -o wide"

echo
echo "Checking kube-system pods..."
ansible masters --become -m command -a "kubectl --kubeconfig=/etc/kubernetes/admin.conf get pods -n kube-system"

echo
echo "Flannel checks passed."
