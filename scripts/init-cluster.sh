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

echo "Initializing Kubernetes cluster..."
ansible-playbook ansible/site.yml --tags kubernetes_cluster

echo
echo "Checking Kubernetes nodes from the control plane..."
ansible masters --become -m command -a "kubectl --kubeconfig=/etc/kubernetes/admin.conf get nodes -o wide"

echo
echo "Checking kube-system pods..."
ansible masters --become -m command -a "kubectl --kubeconfig=/etc/kubernetes/admin.conf get pods -n kube-system"

echo
echo "Kubernetes cluster initialized."
echo "Note: nodes may stay NotReady until a CNI plugin, such as Flannel, is installed."
