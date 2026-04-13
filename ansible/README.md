# Ansible Directory Guide

This directory contains all automation required to bootstrap Linux hosts, install Automation Controller, register managed nodes, patch Linux systems, and perform VMware VM lifecycle operations.

## Directory Layout

- `ansible.cfg`: Default Ansible configuration for this repository
- `requirements.yml`: Required Ansible collections
- `inventories/prod/hosts.yml`: Static inventory for controller and managed Linux nodes
- `inventories/prod/group_vars/all.yml`: Shared controller and Ansible connection variables
- `inventories/prod/group_vars/vcenter.yml`: VMware vCenter connection values and VM lifecycle targets
- `templates/`: Jinja templates used during controller installation
- `playbooks/`: Step-by-step operational playbooks

## Files You Must Edit

### 1. `inventories/prod/group_vars/all.yml`

Update these values before installing Automation Controller:

- `ansible_user`
- `ansible_ssh_private_key_file`
- `controller_fqdn`
- `controller_admin_user`
- `controller_admin_password`
- `aap_installer_bundle_path`

### 2. `inventories/prod/group_vars/vcenter.yml`

Update these values before running VMware-related playbooks:

- `vcenter_hostname`
- `vcenter_username`
- `vcenter_password`
- `vcenter_datacenter`
- `vcenter_cluster`
- `vcenter_folder`
- `vcenter_datastore`
- `vcenter_resource_pool`
- `vcenter_default_portgroup`

Also adjust the target lists:

- `vm_day2_targets`
- `vm_deploy_template_targets`
- `vm_deploy_ova_targets`
- `vm_deploy_iso_targets`

### 3. `inventories/prod/hosts.yml`

Update IP addresses for:

- `automation_controller`
- `managed_linux`

## Execution Order

Run playbooks in this order for a fresh deployment:

```sh
cd ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook -i inventories/prod/hosts.yml playbooks/01-bootstrap-linux.yml
ansible-playbook -i inventories/prod/hosts.yml playbooks/02-install-automation-controller.yml
ansible-playbook -i inventories/prod/hosts.yml playbooks/03-configure-controller-and-inventory.yml
ansible-playbook -i inventories/prod/hosts.yml playbooks/04-linux-patching-demo.yml
```

Run these when you need VMware lifecycle automation:

```sh
ansible-playbook -i inventories/prod/hosts.yml playbooks/05-vm-snapshot-and-day2-change.yml
ansible-playbook -i inventories/prod/hosts.yml playbooks/06-deploy-vm-from-template-ova-iso.yml
```

## Playbook Logic Reference

See `ansible/playbooks/README.md` for detailed logic and variable-by-variable explanations.
