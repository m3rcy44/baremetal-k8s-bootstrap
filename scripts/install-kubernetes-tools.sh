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

echo "Installing Kubernetes tools..."
ansible-playbook ansible/site.yml --tags kubernetes_packages

echo
echo "Checking kubeadm version..."
ansible all -m command -a "kubeadm version --output short"

echo
echo "Checking kubelet version..."
ansible all -m command -a "kubelet --version"

echo
echo "Checking kubectl version..."
ansible all -m command -a "kubectl version --client=true"

echo
echo "Checking held packages..."
ansible all -m shell -a "apt-mark showhold | grep -E '^(kubeadm|kubectl|kubelet)$' | sort"

echo
echo "Kubernetes tools checks passed."
