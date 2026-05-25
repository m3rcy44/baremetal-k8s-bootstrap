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

echo "Installing MetalLB..."
ansible-playbook ansible/site.yml --tags metallb

echo
echo "Checking MetalLB pods..."
ansible masters --become -m command -a "kubectl --kubeconfig=/etc/kubernetes/admin.conf get pods -n metallb-system -o wide"

echo
echo "Checking MetalLB address pool..."
ansible masters --become -m command -a "kubectl --kubeconfig=/etc/kubernetes/admin.conf get ipaddresspool -n metallb-system"

echo
echo "Checking MetalLB L2 advertisement..."
ansible masters --become -m command -a "kubectl --kubeconfig=/etc/kubernetes/admin.conf get l2advertisement -n metallb-system"

echo
echo "MetalLB checks passed."
