#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INVENTORY_DIR="${ROOT_DIR}/ansible/inventory"
INVENTORY_FILE="${INVENTORY_DIR}/hosts.ini"

VM_NAMES=("k8s-master" "k8s-worker-1")

if ! command -v limactl >/dev/null 2>&1; then
  echo "Error: required command 'limactl' is not installed or not in PATH." >&2
  exit 1
fi

for name in "${VM_NAMES[@]}"; do
  if [ ! -d "${HOME}/.lima/${name}" ]; then
    echo "Error: Lima VM '$name' does not exist. Run ./scripts/create-vms.sh first." >&2
    exit 1
  fi

  if [ ! -f "${HOME}/.lima/${name}/ssh.config" ]; then
    echo "Error: SSH config not found: ${HOME}/.lima/${name}/ssh.config" >&2
    echo "Try: limactl start ${name}" >&2
    exit 1
  fi
done

mkdir -p "$INVENTORY_DIR"

cat >"$INVENTORY_FILE" <<EOF
[masters]
k8s-master ansible_host=lima-k8s-master ansible_ssh_common_args='-F {{lookup("env","HOME")}}/.lima/k8s-master/ssh.config'

[workers]
k8s-worker-1 ansible_host=lima-k8s-worker-1 ansible_ssh_common_args='-F {{lookup("env","HOME")}}/.lima/k8s-worker-1/ssh.config'

[k8s_cluster:children]
masters
workers

[all:vars]
ansible_python_interpreter=/usr/bin/python3
EOF

echo "Generated Ansible inventory: ${INVENTORY_FILE}"
echo
cat "$INVENTORY_FILE"
