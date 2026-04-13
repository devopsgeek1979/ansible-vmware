
# Production-Ready Ansible Tower on vSphere

This repository provisions automation infrastructure on VMware vCenter and operationalizes Linux server management through Ansible Tower (Red Hat Ansible Automation Platform Controller, Tower successor).

Primary vCenter endpoint used in this solution:

- `192.168.1.10`

## What You Get

- Terraform stack to provision Tower/Controller VMs and managed Linux VMs in vCenter
- Ansible playbooks to bootstrap servers, install controller nodes, and register managed Linux hosts
- Operations runbooks, failure handling, and security baseline documentation
- Example observability configuration for Prometheus + Loki

## Repository Layout

- `terraform/`: vSphere provisioning for controller and managed Linux nodes
- `ansible/`: bootstrap, controller install/configuration, and Linux operations playbooks
- `docs/`: architecture, deployment guide, runbooks, and examples
- `observability/`: starter Prometheus and Loki configuration
- `screenshots/`: visual artifacts for dashboards and cluster views

## Architecture

`vCenter (192.168.1.10)` → `Terraform` → `Controller VMs + Linux VMs` → `Ansible Automation Controller` → `Managed Linux Fleet`

Reference docs:

- `docs/architecture.md`
- `docs/deployment-guide.md`

## Quick Start

### 1) Provision infrastructure in vSphere

```sh
cd terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

### 2) Prepare Ansible dependencies

```sh
cd ../ansible
ansible-galaxy collection install -r requirements.yml
```

### 3) Update inventory with provisioned IPs

- Edit `ansible/inventories/prod/hosts.yml`
- Fill controller and managed host addresses from `terraform output`

### 4) Bootstrap and install controller

```sh
ansible-playbook -i inventories/prod/hosts.yml playbooks/01-bootstrap-linux.yml
ansible-playbook -i inventories/prod/hosts.yml playbooks/02-install-automation-controller.yml
ansible-playbook -i inventories/prod/hosts.yml playbooks/03-configure-controller-and-inventory.yml
```

### 5) Run Linux management workflow

```sh
ansible-playbook -i inventories/prod/hosts.yml playbooks/04-linux-patching-demo.yml
```

## Production Readiness Highlights

- Idempotent provisioning and automation design
- Dedicated controller and managed node groups
- TLS, RBAC, and secret-handling guidance in `docs/security-baseline.md`
- Incident response guidance in `docs/failure-runbooks.md`

## Notes on Tower Naming

- “Ansible Tower” is now “Automation Controller” in Ansible Automation Platform.
- This repository uses “Tower” and “Controller” consistently where appropriate.

## Next Step

Use the deployment guide in `docs/deployment-guide.md` to perform a full end-to-end rollout in your environment.
