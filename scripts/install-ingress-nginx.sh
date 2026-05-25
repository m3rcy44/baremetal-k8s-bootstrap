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

echo "Installing ingress-nginx..."
ansible-playbook ansible/site.yml --tags ingress_nginx

echo
echo "Checking ingress-nginx pods..."
ansible masters --become -m command -a "kubectl --kubeconfig=/etc/kubernetes/admin.conf get pods -n ingress-nginx -o wide"

echo
echo "Checking ingress-nginx service..."
ansible masters --become -m command -a "kubectl --kubeconfig=/etc/kubernetes/admin.conf get svc -n ingress-nginx ingress-nginx-controller"

echo
echo "Checking ingress class..."
ansible masters --become -m command -a "kubectl --kubeconfig=/etc/kubernetes/admin.conf get ingressclass"

echo
echo "Checking HTTP response through MetalLB IP..."
ansible masters --become -m shell -a "ip=\$(kubectl --kubeconfig=/etc/kubernetes/admin.conf -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'); code=\$(curl -sS -o /dev/null -w '%{http_code}' http://\$ip); echo ingress_ip=\$ip http_status=\$code"

echo
echo "ingress-nginx checks passed."
