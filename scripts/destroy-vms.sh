#!/usr/bin/env bash
set -euo pipefail

VM_NAMES=("k8s-master" "k8s-worker-1")

if ! command -v limactl >/dev/null 2>&1; then
  echo "Error: required command 'limactl' is not installed or not in PATH." >&2
  exit 1
fi

for name in "${VM_NAMES[@]}"; do
  if [ -d "${HOME}/.lima/${name}" ]; then
    echo "Deleting Lima VM '$name'..."
    limactl delete --force "$name"
  else
    echo "VM '$name' does not exist. Skipping."
  fi
done

echo "Done."
