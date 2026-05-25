# Bare-metal Kubernetes Automation

Automated local Kubernetes platform built with Lima, Ansible, kubeadm, Flannel, MetalLB, ingress-nginx, kube-prometheus-stack, and a FastAPI demo app. No cloud providers required.

## Stack

- Lima Ubuntu VMs
- Ansible provisioning
- containerd
- kubeadm / kubelet / kubectl
- Flannel CNI
- MetalLB
- ingress-nginx
- FastAPI demo app, 3 replicas
- kube-prometheus-stack without Alertmanager

## Requirements

- `limactl`
- `ansible`
- `socket_vmnet`

Lima shared networking expects:

```text
/opt/socket_vmnet/bin/socket_vmnet
```

Minimal `socket_vmnet` install:

```bash
git clone https://github.com/lima-vm/socket_vmnet
cd socket_vmnet
git checkout v1.2.2
make
sudo make PREFIX=/opt/socket_vmnet install.bin

limactl sudoers > etc_sudoers.d_lima
sudo install -o root etc_sudoers.d_lima /etc/sudoers.d/lima
rm etc_sudoers.d_lima
```

## Quick Start

```bash
git clone <repo>
cd baremetal-k8s-automation
./scripts/setup-cluster.sh
```

This creates two Lima VMs and deploys the full local Kubernetes stack.

## What Gets Deployed

- `k8s-master`
- `k8s-worker-1`
- Kubernetes cluster via `kubeadm`
- Flannel pod networking
- MetalLB IP pool: `192.168.105.240-192.168.105.250`
- ingress-nginx with external IP from MetalLB
- FastAPI demo app with `/health`, `/info`, `/metrics`
- Grafana and Prometheus in `monitoring`

## Access

Kubernetes:

```bash
limactl shell k8s-master
kubectl get nodes
kubectl get pods -A
```

Demo app:

```text
http://192.168.105.240/info
http://192.168.105.240/health
http://192.168.105.240/metrics
```

Grafana:

```text
http://grafana.local
```

Add to `/etc/hosts` on the host machine:

```text
192.168.105.240 grafana.local
```

Default Grafana credentials:

```text
admin / admin
```

## Scripts

Full setup:

```bash
./scripts/setup-cluster.sh
```

Destroy VMs:

```bash
./scripts/destroy-vms.sh
```

Run steps manually:

```bash
./scripts/setup-base.sh
./scripts/init-cluster.sh
./scripts/install-flannel.sh
./scripts/install-metallb.sh
./scripts/install-ingress-nginx.sh
./scripts/deploy-demo-app.sh
./scripts/install-monitoring.sh
```

Reset only Kubernetes state:

```bash
./scripts/reset-cluster.sh
```

## Demo App Check

```bash
limactl shell k8s-master
kubectl get pods -n demo -o wide
kubectl get rs -n demo
```

Repeated calls show traffic going to different pods:

```bash
curl http://192.168.105.240/info
```

## Notes

- The project does not use AWS, GCP, Azure, Hetzner, or other cloud providers.
- `socket_vmnet` is required for Lima shared networking.
- `setup-base.sh` only prepares the VMs; use `setup-cluster.sh` for the full platform.
