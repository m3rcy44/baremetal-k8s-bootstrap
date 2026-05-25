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

echo "Installing and configuring containerd..."
ansible-playbook ansible/site.yml --tags container_runtime

echo
echo "Checking containerd version..."
ansible all -m command -a "containerd --version"

echo
echo "Checking containerd service..."
ansible all -m command -a "systemctl is-active containerd"

echo
echo "Checking containerd cgroup driver..."
ansible all -m shell -a "grep -E '^\\s*SystemdCgroup = true' /etc/containerd/config.toml"

echo
echo "containerd checks passed."
