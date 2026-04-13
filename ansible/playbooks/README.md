# Playbook Guide

This document explains every playbook in `ansible/playbooks/`, what logic it runs, and where you must change values for your own VMware vCenter and Linux environment.

## Before You Run Any Playbook

Update these files first:

- `ansible/inventories/prod/hosts.yml`
- `ansible/inventories/prod/group_vars/all.yml`
- `ansible/inventories/prod/group_vars/vcenter.yml`

## 01 - `01-bootstrap-linux.yml`

### 01 Purpose

Bootstraps all controller and managed Linux hosts with required base packages and services.

### 01 Logic

This playbook:

- installs Python, pip, curl, git, unzip, rsync, firewalld, and chrony
- ensures `chronyd` is enabled and started
- ensures `firewalld` is enabled and started

### 01 Where to change values

Edit `ansible/inventories/prod/hosts.yml` if your controller and Linux host IPs differ.

Edit `ansible/inventories/prod/group_vars/all.yml` if your SSH user or key path differs:

- `ansible_user`
- `ansible_ssh_private_key_file`
- `ansible_become`

### 01 Run

```sh
cd ansible
ansible-playbook -i inventories/prod/hosts.yml playbooks/01-bootstrap-linux.yml
```

## 02 - `02-install-automation-controller.yml`

### 02 Purpose

Installs Ansible Automation Platform Controller on the hosts in the `automation_controller` inventory group.

### 02 Logic

This playbook:

- verifies the installer bundle path exists
- fails early if the installer bundle is missing
- renders installer inventory from `templates/aap-installer-inventory.ini.j2`
- runs `setup.sh` from the installer bundle directory

### 02 Where to change values

Edit `ansible/inventories/prod/group_vars/all.yml`:

- `aap_installer_bundle_path`
- `controller_admin_user`
- `controller_admin_password`

Edit the template-generated values if needed in:

- `ansible/templates/aap-installer-inventory.ini.j2`

### 02 Run

```sh
cd ansible
ansible-playbook -i inventories/prod/hosts.yml playbooks/02-install-automation-controller.yml
```

## 03 - `03-configure-controller-and-inventory.yml`

### 03 Purpose

Configures Controller after installation by creating organization, inventory, and managed Linux host entries.

### 03 Logic

This playbook:

- connects to Controller API using the `awx.awx` collection
- ensures the organization exists
- ensures the inventory exists
- loops through `managed_linux` hosts and registers them into Controller

### 03 Where to change values

Edit `ansible/inventories/prod/group_vars/all.yml`:

- `controller_fqdn`
- `controller_admin_user`
- `controller_admin_password`
- `controller_inventory_name`
- `controller_organization`
- `controller_validate_certs`

Edit `ansible/inventories/prod/hosts.yml` to control which Linux hosts get registered.

### 03 Run

```sh
cd ansible
ansible-playbook -i inventories/prod/hosts.yml playbooks/03-configure-controller-and-inventory.yml
```

## 04 - `04-linux-patching-demo.yml`

### 04 Purpose

Runs Linux patching and baseline package enforcement on managed Linux hosts.

### 04 Logic

This playbook:

- updates APT metadata on Debian and Ubuntu systems
- performs distribution upgrades on Debian and Ubuntu
- performs `dnf` package upgrades on Red Hat family systems
- ensures `audit`, `rsyslog`, and `sudo` are installed

### 04 Where to change values

Edit `ansible/inventories/prod/hosts.yml` to decide which hosts are in the `managed_linux` group.

If your environment requires other baseline packages, update the package list directly in:

- `ansible/playbooks/04-linux-patching-demo.yml`

### 04 Run

```sh
cd ansible
ansible-playbook -i inventories/prod/hosts.yml playbooks/04-linux-patching-demo.yml
```

## 05 - `05-vm-snapshot-and-day2-change.yml`

### 05 Purpose

Creates a snapshot before change and then applies VM day-2 changes in vCenter.

### 05 Logic

This playbook runs from `localhost` and uses `community.vmware` modules to:

- create a snapshot for every VM in `vm_day2_targets`
- update CPU and memory values
- update the VM network adapter mapping
- add an additional data disk to the VM

### 05 Where to change values

Edit `ansible/inventories/prod/group_vars/vcenter.yml`:

Connection settings:

- `vcenter_hostname`
- `vcenter_username`
- `vcenter_password`
- `vcenter_validate_certs`
- `vcenter_datacenter`
- `vcenter_folder`
- `vcenter_datastore`

Per-VM day-2 settings:

- `vm_day2_targets[].name`
- `vm_day2_targets[].snapshot_name`
- `vm_day2_targets[].snapshot_description`
- `vm_day2_targets[].cpu`
- `vm_day2_targets[].memory_mb`
- `vm_day2_targets[].additional_disk_gb`
- `vm_day2_targets[].network_name`
- `vm_day2_targets[].network_type`

### 05 Run

```sh
cd ansible
ansible-playbook -i inventories/prod/hosts.yml playbooks/05-vm-snapshot-and-day2-change.yml
```

## 06 - `06-deploy-vm-from-template-ova-iso.yml`

### 06 Purpose

Deploys new VMs in vCenter using three patterns:

- template clone
- OVA/OVF deployment
- ISO-based VM shell deployment

### 06 Logic

This playbook runs from `localhost` and:

- deploys VMs from templates using `community.vmware.vmware_guest`
- deploys VMs from OVA using `community.vmware.vmware_deploy_ovf`
- creates new VM shells with ISO attached for unattended OS installation

### 06 Where to change values

Edit `ansible/inventories/prod/group_vars/vcenter.yml`.

Common connection values:

- `vcenter_hostname`
- `vcenter_username`
- `vcenter_password`
- `vcenter_datacenter`
- `vcenter_cluster`
- `vcenter_folder`
- `vcenter_datastore`

Template deployment values:

- `vm_deploy_template_targets[].name`
- `vm_deploy_template_targets[].template`
- `vm_deploy_template_targets[].cpu`
- `vm_deploy_template_targets[].memory_mb`
- `vm_deploy_template_targets[].disk_gb`
- `vm_deploy_template_targets[].network_name`

OVA deployment values:

- `vm_deploy_ova_targets[].name`
- `vm_deploy_ova_targets[].ova_path`
- `vm_deploy_ova_targets[].cpu`
- `vm_deploy_ova_targets[].memory_mb`
- `vm_deploy_ova_targets[].network_name`

ISO deployment values:

- `vm_deploy_iso_targets[].name`
- `vm_deploy_iso_targets[].guest_id`
- `vm_deploy_iso_targets[].iso_path`
- `vm_deploy_iso_targets[].cpu`
- `vm_deploy_iso_targets[].memory_mb`
- `vm_deploy_iso_targets[].disk_gb`
- `vm_deploy_iso_targets[].network_name`

### 06 Run

```sh
cd ansible
ansible-playbook -i inventories/prod/hosts.yml playbooks/06-deploy-vm-from-template-ova-iso.yml
```

## Recommended Safe Order

If you are using this repo with your own vCenter, use this order:

1. Update all inventory and group variable files
1. Test connectivity to Linux hosts and vCenter
1. Run `01-bootstrap-linux.yml`
1. Run `02-install-automation-controller.yml`
1. Run `03-configure-controller-and-inventory.yml`
1. Run `04-linux-patching-demo.yml`
1. Run `05-vm-snapshot-and-day2-change.yml` only after confirming the VM names and storage values are correct
1. Run `06-deploy-vm-from-template-ova-iso.yml` only after confirming template, OVA, and ISO paths are valid in your vCenter environment
