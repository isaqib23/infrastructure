# Hetzner Cloud Kubernetes Infrastructure

This repository contains Ansible playbooks to deploy and manage Kubernetes infrastructure on Hetzner Cloud with separate staging and production environments.

## 🏗️ Architecture

- **Staging**: 1 master (cax21) + 3 workers (cx21)
- **Production**: 1 master (cax41) + 3 workers (cax21)
- **Networking**: Private network (172.16.0.0/24) with public IPs
- **OS**: Ubuntu 24.04 LTS

## 📋 Prerequisites

1. **Hetzner Cloud Account** with API tokens for staging and production
2. **Ansible** installed (>= 4.30.0)
3. **SSH Key pair** for server access

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone <your-repo>
cd hetzner-infrastructure
cp .env.example .env
```

### 2. Configure Environment Variables

Edit `.env` file:

```bash
# Hetzner Cloud API tokens
HCLOUD_API_TOKEN_STAGING=your-staging-token-here
HCLOUD_API_TOKEN_PRODUCTION=your-production-token-here

# SSH Public Key
SSH_PUBLIC_KEY=ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILteMamIwKF32iwvJkqrvQgPmbgLiET+DsJ9rTrj/eAX user@example.com
```

### 3. Install Dependencies

```bash
ansible-galaxy collection install -r requirements.yml
```

## 🎯 Deployment

### Deploy to Staging

```bash
./scripts/deploy-staging.sh
```

### Deploy to Production

```bash
./scripts/deploy-production.sh
```

### Manual Deployment

```bash
# Staging
ansible-playbook -i inventories/staging/hosts.yml playbooks/infrastructure.yml

# Production
ansible-playbook -i inventories/production/hosts.yml playbooks/infrastructure.yml
```

## 🧹 Cleanup

### Remove Staging Environment

```bash
./scripts/cleanup.sh staging
```

### Remove Production Environment

```bash
./scripts/cleanup.sh production
```

## 📁 Project Structure

```
hetzner-infrastructure/
├── inventories/
│   ├── staging/              # Staging environment config
│   └── production/           # Production environment config
├── playbooks/               # Main playbooks
├── roles/                   # Ansible roles
├── scripts/                 # Deployment scripts
└── group_vars/             # Global variables
```

## 🔧 Configuration

### Environment Differences

| Feature | Staging | Production |
|---------|---------|------------|
| Master Server | cax21 | cax41 |
| Worker Nodes | 2x cx21 | 3x cax21 |
| Prefix | stg- | prod- |
| Monitoring | Optional | Enabled |
| Backups | Optional | Enabled |

### Customization

Edit environment-specific variables in:
- `inventories/staging/group_vars/all.yml`
- `inventories/production/group_vars/all.yml`

## 🔐 Security Best Practices

1. **API Tokens**: Store in `.env` file (gitignored)
2. **SSH Keys**: Use separate keys for different environments
3. **Network**: Private network isolation
4. **Access**: Firewall rules (configure post-deployment)

## 📊 Monitoring & Maintenance

### Check Infrastructure Status

```bash
# List all servers
ansible-playbook -i inventories/staging/hosts.yml playbooks/info.yml

# Health check
ansible all -i inventories/staging/dynamic_hosts.yml -m ping
```

### Scaling

To add more worker nodes, update the `worker_nodes` list in the environment's `group_vars/all.yml` and re-run the deployment.

## 🚨 Troubleshooting

### Common Issues

1. **API Token Issues**
   ```bash
   # Verify token works
   curl -H "Authorization: Bearer $HCLOUD_API_TOKEN_STAGING" https://api.hetzner.cloud/v1/servers
   ```

2. **SSH Connection Issues**
   ```bash
   # Test SSH access
   ssh root@<server-ip> -i ~/.ssh/your-private-key
   ```

3. **Network Conflicts**
   ```bash
   # Check existing networks
   ansible-playbook playbooks/cleanup.yml # Remove conflicting resources
   ```

### Debug Mode

Run with verbose output:
```bash
ansible-playbook -i inventories/staging/hosts.yml playbooks/infrastructure.yml -vvv
```

## 🔄 CI/CD Integration

### GitHub Actions Example

```yaml
name: Deploy Infrastructure
on:
  push:
    branches: [main]
    paths: ['inventories/production/**']

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to Production
        env:
          HCLOUD_API_TOKEN_PRODUCTION: ${{ secrets.HCLOUD_API_TOKEN_PRODUCTION }}
          SSH_PUBLIC_KEY: ${{ secrets.SSH_PUBLIC_KEY }}
        run: ./scripts/deploy-production.sh
```

## 📝 Next Steps

After infrastructure deployment:

1. **Configure Kubernetes**: Install kubeadm, kubelet, kubectl
2. **Set up Ingress**: Configure load balancer
3. **Enable Monitoring**: Prometheus, Grafana
4. **Configure Backups**: Automated snapshots
5. **Security Hardening**: Firewall, fail2ban, updates

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test changes in staging
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

- Check the [troubleshooting section](#-troubleshooting)
- Review Hetzner Cloud [documentation](https://docs.hetzner.cloud/)
- Open an issue for bugs or feature requests