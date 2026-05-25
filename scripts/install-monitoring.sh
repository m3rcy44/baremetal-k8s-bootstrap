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

echo "Installing kube-prometheus-stack..."
ansible-playbook ansible/site.yml --tags monitoring_stack

echo
echo "Checking monitoring pods..."
ansible masters --become -m command -a "kubectl --kubeconfig=/etc/kubernetes/admin.conf get pods -n monitoring -o wide"

echo
echo "Checking monitoring services..."
ansible masters --become -m command -a "kubectl --kubeconfig=/etc/kubernetes/admin.conf get svc -n monitoring"

echo
echo "Checking Grafana ingress..."
ansible masters --become -m command -a "kubectl --kubeconfig=/etc/kubernetes/admin.conf get ingress -n monitoring"

echo
echo "Checking Grafana HTTP response through ingress-nginx..."
ansible masters --become -m shell -a "ingress_ip=\$(kubectl --kubeconfig=/etc/kubernetes/admin.conf -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'); code=\$(curl -sS -o /dev/null -w '%{http_code}' -H 'Host: grafana.local' http://\$ingress_ip); echo grafana_host=grafana.local ingress_ip=\$ingress_ip http_status=\$code"

echo
echo "Monitoring checks passed."
