# VM Lifecycle Automation (Snapshot + Day-2 + New Provisioning)

This guide covers automation for:

- Pre-change snapshots on existing VMs
- CPU, memory, disk, and network updates on existing VMs
- New VM deployment from template, OVA, and ISO

vCenter target:

- `192.168.1.10`

## 1) Ansible Day-2 Operations on Existing VMs

Edit `ansible/inventories/prod/group_vars/vcenter.yml` and populate:

- `vcenter_hostname`, `vcenter_username`, `vcenter_password`
- `vm_day2_targets` list

Run snapshot + changes:

```sh
cd ansible
ansible-playbook -i inventories/prod/hosts.yml playbooks/05-vm-snapshot-and-day2-change.yml
```

This flow:

- Creates snapshot before changes
- Applies CPU and memory changes
- Updates VM network adapter mapping
- Adds additional HDD

## 2) Ansible New VM Provisioning

Configure in `ansible/inventories/prod/group_vars/vcenter.yml`:

- `vm_deploy_template_targets`
- `vm_deploy_ova_targets`
- `vm_deploy_iso_targets`

Run:

```sh
cd ansible
ansible-playbook -i inventories/prod/hosts.yml playbooks/06-deploy-vm-from-template-ova-iso.yml
```

## 3) Terraform Existing VM Day-2 Management

Terraform can manage existing VMs after import.

1. Copy lifecycle vars example:

```sh
cd terraform
cp vm-lifecycle.auto.tfvars.example vm-lifecycle.auto.tfvars
```

1. Update `managed_existing_vms` with real VM metadata.

1. Import each existing VM into Terraform state:

```sh
terraform import 'vsphere_virtual_machine.managed_existing["linux01"]' '/DC1/vm/Automation/ansible-linux-01'
```

1. Plan and apply:

```sh
terraform init
terraform plan -var-file=terraform.tfvars -var-file=vm-lifecycle.auto.tfvars
terraform apply -var-file=terraform.tfvars -var-file=vm-lifecycle.auto.tfvars
```

## 4) Terraform New VM Deployment Modes

Use the same `vm-lifecycle.auto.tfvars` file:

- `template_deployments` for template clone
- `ova_deployments` for OVA/OVF import
- `iso_deployments` for ISO-based VM shell creation

Apply:

```sh
terraform plan -var-file=terraform.tfvars -var-file=vm-lifecycle.auto.tfvars
terraform apply -var-file=terraform.tfvars -var-file=vm-lifecycle.auto.tfvars
```

## 5) ISO Auto Provisioning Notes

ISO automation typically needs unattended installation:

- Linux Kickstart/Preseed/Autoinstall
- Windows Autounattend.xml

The Terraform and Ansible ISO flows create/power VM shells with ISO attached; full OS installation automation requires unattended boot parameters and answer files in your environment.
