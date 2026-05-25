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

if ! ansible all --list-hosts | grep -q "k8s-master"; then
  echo "Error: Ansible inventory does not contain expected Lima hosts." >&2
  echo "Run: ./scripts/generate-inventory.sh" >&2
  exit 1
fi

echo "Checking SSH connectivity..."
ansible all -m ping

echo
echo "Checking passwordless sudo..."
ansible all -m command -a "whoami" --become

echo
echo "Base Ansible checks passed."
