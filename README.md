
# Production-Ready Ansible Tower on vSphere

This repository shows how to provision VMware vSphere infrastructure, deploy Ansible Tower / Automation Controller, onboard Linux servers, and automate day-2 VM lifecycle operations from a single codebase.

The reference vCenter used in this project is:

- `192.168.1.10`

## Repository Description

Production-grade Infrastructure as Code and Automation-as-Code solution for VMware vCenter that covers:

- new VM provisioning from template, OVA, and ISO patterns
- installation of Ansible Tower / Automation Controller
- onboarding and management of Linux servers
- VM snapshots before change windows
- CPU, memory, disk, and network changes for existing VMs

**GitHub short description:**
`Production-ready Ansible Tower on vSphere (192.168.1.10) with Terraform provisioning, Controller setup, Linux fleet management, and VM lifecycle automation.`

## What This Repo Does

- Provisions controller and Linux VMs in VMware vCenter using Terraform
- Installs and configures Automation Controller using Ansible
- Registers Linux servers into the controller inventory
- Demonstrates patching and compliance jobs for Linux hosts
- Automates VM lifecycle tasks such as snapshot, resize, disk add, network update, and new VM deployment

## Repository Structure

- `terraform/`: Infrastructure provisioning and VM lifecycle definitions
- `ansible/`: Ansible config, inventories, variables, templates, and playbooks
- `ansible/playbooks/`: Playbooks for bootstrap, controller install, Linux operations, and vCenter VM automation
- `docs/`: Architecture, deployment guide, security baseline, runbooks, and VM lifecycle guide
- `observability/`: Prometheus and Loki baseline configs

## Files You Must Update For Your Environment

Before running anything, update these files with your own values:

### vCenter connection values

- `ansible/inventories/prod/group_vars/vcenter.yml`
- `terraform/terraform.tfvars`
- `terraform/vm-lifecycle.auto.tfvars`

Change at minimum:

- `vcenter_hostname`
- `vcenter_username`
- `vcenter_password`
- `vcenter_datacenter`
- `vcenter_cluster`
- `vcenter_folder`
- `vcenter_datastore`
- `vcenter_default_portgroup`

### Automation Controller values

- `ansible/inventories/prod/group_vars/all.yml`

Change at minimum:

- `controller_fqdn`
- `controller_admin_user`
- `controller_admin_password`
- `aap_installer_bundle_path`

### Inventory host IPs

- `ansible/inventories/prod/hosts.yml`

Update:

- controller node IPs
- managed Linux node IPs

## Step-by-Step Execution Flow

## 1. Prepare Terraform variables

```sh
cd terraform
cp terraform.tfvars.example terraform.tfvars
cp vm-lifecycle.auto.tfvars.example vm-lifecycle.auto.tfvars
```

Edit both files and replace all example values with your own vCenter environment values.

## 2. Provision base infrastructure in vCenter

```sh
terraform init
terraform plan
terraform apply
```

This creates the controller and Linux VM estate defined in Terraform.

## 3. Collect VM IP addresses

```sh
terraform output
```

Use the output values to update:

- `ansible/inventories/prod/hosts.yml`

## 4. Install Ansible collections

```sh
cd ../ansible
ansible-galaxy collection install -r requirements.yml
```

## 5. Bootstrap controller and Linux hosts

```sh
ansible-playbook -i inventories/prod/hosts.yml playbooks/01-bootstrap-linux.yml
```

This prepares target hosts with required packages and baseline services.

## 6. Install Automation Controller

```sh
ansible-playbook -i inventories/prod/hosts.yml playbooks/02-install-automation-controller.yml
```

This uses the installer bundle referenced by `aap_installer_bundle_path`.

## 7. Register Linux servers in Controller

```sh
ansible-playbook -i inventories/prod/hosts.yml playbooks/03-configure-controller-and-inventory.yml
```

This creates the organization, inventory, and managed host records in Controller.

## 8. Run Linux operations

```sh
ansible-playbook -i inventories/prod/hosts.yml playbooks/04-linux-patching-demo.yml
```

This demonstrates package patching and baseline package enforcement.

## 9. Run VM lifecycle automation

For snapshots and day-2 changes:

```sh
ansible-playbook -i inventories/prod/hosts.yml playbooks/05-vm-snapshot-and-day2-change.yml
```

For template, OVA, and ISO VM deployment:

```sh
ansible-playbook -i inventories/prod/hosts.yml playbooks/06-deploy-vm-from-template-ova-iso.yml
```

For Terraform-driven lifecycle provisioning:

```sh
cd ../terraform
terraform plan -var-file=terraform.tfvars -var-file=vm-lifecycle.auto.tfvars
terraform apply -var-file=terraform.tfvars -var-file=vm-lifecycle.auto.tfvars
```

## Playbook Documentation

Detailed playbook explanations are available here:

- `ansible/README.md`
- `ansible/playbooks/README.md`

These documents explain:

- what each playbook does
- the code logic used inside it
- which variables it depends on
- exactly where to change values for your vCenter environment

## Supporting Documentation

- `docs/architecture.md`
- `docs/deployment-guide.md`
- `docs/failure-runbooks.md`
- `docs/security-baseline.md`
- `docs/vm-lifecycle-automation.md`

## Notes

- “Ansible Tower” is now called “Automation Controller” in Ansible Automation Platform.
- This repo uses the terms “Tower” and “Controller” to help users familiar with older naming.
- ISO deployment in automation typically requires unattended install assets such as Kickstart, Preseed, or Autoinstall.

## Recommended Next Step

Start with `ansible/playbooks/README.md` if you want to understand the logic of every playbook before running the repo.
