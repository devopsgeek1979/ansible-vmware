# Security Baseline

## Identity and Access

- Enforce SSO (SAML/OIDC) for controller users
- Restrict admin role assignment to platform team
- Use RBAC for project, inventory, and credential scopes

## Secrets Management

- Store secrets in controller credentials, not playbooks
- Integrate external vault where possible
- Rotate API and SSH credentials on a defined interval

## Host Hardening

- Use hardened golden templates in vSphere
- Enforce CIS-aligned baseline on all Linux nodes
- Keep SSH key-based access only and disable password login

## Network Security

- Restrict management plane access to known subnets
- Terminate TLS with trusted certificates
- Segment controller and managed networks with firewall policies

## Audit and Monitoring

- Enable controller activity stream retention
- Ship logs to Loki/SIEM
- Create alerts for failed jobs, unreachable hosts, and auth anomalies
