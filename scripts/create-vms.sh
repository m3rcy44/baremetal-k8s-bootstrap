#!/usr/bin/env bash
set -euo pipefail

VM_NAMES=("k8s-master" "k8s-worker-1")

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: required command '$1' is not installed or not in PATH." >&2
    exit 1
  fi
}

require_socket_vmnet() {
  if [ ! -x /opt/socket_vmnet/bin/socket_vmnet ]; then
    cat >&2 <<'EOF'
Error: socket_vmnet is required for Lima shared networking.

The Kubernetes VMs use `networks: - lima: shared`, so Lima expects:
  /opt/socket_vmnet/bin/socket_vmnet

Install socket_vmnet, then rerun:
  ./scripts/create-vms.sh

See README.md for the short install notes.
EOF
    exit 1
  fi
}

create_vm() {
  local name="$1"
  local cpus="$2"
  local memory="$3"
  local disk="$4"

  if [ -d "${HOME}/.lima/${name}" ]; then
    echo "VM '$name' already exists. Skipping creation."
    limactl start "$name" >/dev/null
    return
  fi

  echo "Creating Lima VM '$name'..."
  limactl create --name="$name" --tty=false - <<EOF
images:
  - location: "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-arm64.img"
    arch: "aarch64"
  - location: "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img"
    arch: "x86_64"
cpus: ${cpus}
memory: "${memory}"
disk: "${disk}"
mounts: []
networks:
  - lima: shared
ssh:
  loadDotSSHPubKeys: true
containerd:
  system: false
  user: false
EOF

  limactl start "$name"
}

require_command limactl
require_socket_vmnet

create_vm "k8s-master" "2" "3GiB" "25GiB"
create_vm "k8s-worker-1" "2" "3GiB" "25GiB"

echo
echo "Lima VMs are ready:"
limactl list "${VM_NAMES[@]}"
