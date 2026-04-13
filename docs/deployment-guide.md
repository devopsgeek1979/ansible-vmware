# Deployment Guide

## Prerequisites

- Terraform `>= 1.6`
- Ansible `>= 2.15`
- Access to vCenter at `192.168.1.10`
- A Linux VM template in vSphere (`template_name` in Terraform)
- Red Hat subscription and Automation Platform installer bundle

## Step 1: Configure Terraform

```sh
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Update `terraform.tfvars` values for datacenter, cluster, datastore, network, and credentials.

## Step 2: Provision VMs

```sh
terraform init
terraform plan
terraform apply
```

Capture output addresses:

```sh
terraform output tower_vm_ips
terraform output managed_linux_vm_ips
```

## Step 3: Update Ansible Inventory

Edit `ansible/inventories/prod/hosts.yml` with IPs from Terraform outputs.

## Step 4: Install Dependencies

```sh
cd ../ansible
ansible-galaxy collection install -r requirements.yml
```

## Step 5: Bootstrap and Install Controller

```sh
ansible-playbook -i inventories/prod/hosts.yml playbooks/01-bootstrap-linux.yml
ansible-playbook -i inventories/prod/hosts.yml playbooks/02-install-automation-controller.yml
```

## Step 6: Register Managed Linux Servers

```sh
ansible-playbook -i inventories/prod/hosts.yml playbooks/03-configure-controller-and-inventory.yml
```

## Step 7: Execute Linux Management Jobs

```sh
ansible-playbook -i inventories/prod/hosts.yml playbooks/04-linux-patching-demo.yml
```

## Post-Deployment Validation

```sh
ansible -i inventories/prod/hosts.yml all -m ping
ansible -i inventories/prod/hosts.yml managed_linux -m shell -a "hostnamectl"
```

Validate controller web access at `https://<controller_fqdn>`.
