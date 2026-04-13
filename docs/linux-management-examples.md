# Linux Management Examples via Tower/Controller

## Example 1: Security Updates

Use `playbooks/04-linux-patching-demo.yml` as a Job Template in controller:

- Inventory: `linux-prod`
- Credentials: SSH machine credential
- Limit: `managed_linux`

Expected result:

- Package patching completed on all Linux nodes
- Compliance baseline packages enforced

## Example 2: New Server Onboarding

1. Provision VM in vSphere with Terraform by increasing `managed_linux_count`.
2. Update inventory with the new server details.
3. Re-run:

```sh
ansible-playbook -i inventories/prod/hosts.yml playbooks/03-configure-controller-and-inventory.yml
```

1. Trigger patching job in controller UI/API.

## Example 3: Service Standardization

Create a playbook for standard service state across hosts:

```yaml
---
- name: Enforce sshd and rsyslog state
  hosts: managed_linux
  become: true
  tasks:
    - name: Ensure sshd enabled and running
      ansible.builtin.service:
        name: sshd
        enabled: true
        state: started

    - name: Ensure rsyslog enabled and running
      ansible.builtin.service:
        name: rsyslog
        enabled: true
        state: started
```

## Example 4: Drift Detection

- Schedule periodic jobs from controller
- Notify Slack/Teams on failed checks
- Use smart inventories for out-of-policy nodes
