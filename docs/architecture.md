# Architecture

## Target Topology

- vCenter: `192.168.1.10`
- Automation controller nodes: `tower-01`, `tower-02`
- Managed Linux fleet: `linux-01`, `linux-02`, `linux-03`

## Logical Flow

1. Terraform authenticates to vCenter and clones VMs from a hardened template.
2. Tower/Controller nodes are provisioned in the `Automation` folder.
3. Managed Linux servers are provisioned in the same environment.
4. Ansible bootstraps all hosts and installs Automation Controller.
5. Controller inventory is populated with managed Linux nodes.
6. Linux lifecycle operations run through controller job templates.

## Networking

- Controller-to-managed nodes: SSH/TCP `22`
- User-to-controller: HTTPS/TCP `443`
- vCenter API: HTTPS/TCP `443`
- Observability: node_exporter/TCP `9100`, Loki/TCP `3100`

## High Availability Guidance

- Minimum two controller nodes
- Dedicated DB node or external PostgreSQL for larger environments
- Load balancer VIP in front of controller UI/API
- Backup and recovery policy for controller database and projects
