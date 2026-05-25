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

echo "Deploying FastAPI demo app..."
ansible masters --become -m copy -a "src=k8s/demo-app.yaml dest=/tmp/demo-app.yaml mode=0644"
ansible masters --become -m command -a "kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f /tmp/demo-app.yaml"

echo
echo "Waiting for demo app rollout..."
ansible masters --become -m command -a "kubectl --kubeconfig=/etc/kubernetes/admin.conf -n demo rollout status deployment/fastapi-demo --timeout=300s"

echo
echo "Checking demo pods..."
ansible masters --become -m command -a "kubectl --kubeconfig=/etc/kubernetes/admin.conf get pods -n demo -o wide"

echo
echo "Checking demo ReplicaSet..."
ansible masters --become -m command -a "kubectl --kubeconfig=/etc/kubernetes/admin.conf get rs -n demo"

echo
echo "Checking demo Service and Ingress..."
ansible masters --become -m command -a "kubectl --kubeconfig=/etc/kubernetes/admin.conf get svc,ingress -n demo"

echo
echo "Calling /info through ingress-nginx several times..."
ansible masters --become -m shell -a "ingress_ip=\$(kubectl --kubeconfig=/etc/kubernetes/admin.conf -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'); for i in \$(seq 1 10); do curl -sS http://\$ingress_ip/info; echo; done"

echo
echo "Demo app checks passed."
