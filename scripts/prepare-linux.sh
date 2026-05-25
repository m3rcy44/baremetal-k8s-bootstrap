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

echo "Preparing Linux hosts for Kubernetes..."
ansible-playbook ansible/site.yml --tags linux_prepare

echo
echo "Checking swap state..."
ansible all -m command -a "swapon --show"

echo
echo "Checking kernel modules..."
ansible all -m shell -a "lsmod | grep -E '^(overlay|br_netfilter)'"

echo
echo "Checking sysctl values..."
ansible all -m command -a "sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward"

echo
echo "Linux preparation checks passed."
