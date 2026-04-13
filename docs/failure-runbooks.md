
# Failure Runbooks

This document provides first-response procedures for common production incidents in this platform.

## 1. Controller UI/API Unreachable

### Controller Symptoms

- `https://<controller_fqdn>` does not load
- API calls fail with `5xx` or timeout

### Controller Checks

```sh
ansible automation-controller -i inventories/prod/hosts.yml -m ping
ansible automation-controller -i inventories/prod/hosts.yml -b -m shell -a "systemctl status automation-controller"
ansible automation-controller -i inventories/prod/hosts.yml -b -m shell -a "ss -tulpn | grep -E ':80|:443'"
```

### Controller Recovery

```sh
ansible automation-controller -i inventories/prod/hosts.yml -b -m shell -a "systemctl restart automation-controller"
```

### Post-Incident

- Export service logs and attach to incident ticket
- Verify job execution and callback functionality

## 2. vCenter Connectivity Failure

### vCenter Connectivity Symptoms

- Terraform fails against `192.168.1.10`
- VM lifecycle actions timeout

### vCenter Connectivity Checks

```sh
ping -c 4 192.168.1.10
nc -zv 192.168.1.10 443
```

### vCenter Connectivity Recovery

- Validate network path and DNS resolution to vCenter
- Confirm service health in vCenter appliance management
- Retry Terraform with state lock awareness

## 3. Managed Linux Hosts Not Reachable by Tower

### Linux Reachability Symptoms

- Inventory sync fails
- Job templates fail with `UNREACHABLE`

### Linux Reachability Checks

```sh
ansible managed_linux -i inventories/prod/hosts.yml -m ping
ansible managed_linux -i inventories/prod/hosts.yml -b -m shell -a "systemctl status sshd"
```

### Linux Reachability Recovery

- Revalidate SSH keys/credentials in Tower credentials store
- Confirm firewall rules allow controller-to-host SSH
- Re-run onboarding playbook:

```sh
ansible-playbook -i inventories/prod/hosts.yml playbooks/03-configure-controller-and-inventory.yml
```

## 4. Job Queue Backlog or Slow Execution

### Queue Backlog Checks

- Check controller CPU, memory, and DB performance
- Validate project updates and SCM webhook reachability

### Queue Backlog Recovery

- Increase execution capacity in controller topology
- Scale out controller/worker nodes if queue pressure persists

## Incident Data to Capture

- Start time, blast radius, impacted teams
- Controller logs, system metrics, recent changes
- Recovery actions and exact commands executed

## Exit Criteria

- Controller API reachable and healthy
- Scheduled and ad hoc jobs succeed
- Managed Linux inventory sync passes
