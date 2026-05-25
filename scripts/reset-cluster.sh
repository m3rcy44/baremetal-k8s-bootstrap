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

echo "Resetting Kubernetes cluster state..."
ansible all --become -m command -a "kubeadm reset --force"

echo
echo "Cleaning Kubernetes state directories..."
ansible all --become -m file -a "path=/etc/kubernetes state=absent"
ansible all --become -m file -a "path=/var/lib/etcd state=absent"
ansible all --become -m file -a "path=/etc/cni/net.d state=absent"

echo
echo "Restarting kubelet..."
ansible all --become -m service -a "name=kubelet state=restarted"

echo
echo "Kubernetes cluster state reset."
