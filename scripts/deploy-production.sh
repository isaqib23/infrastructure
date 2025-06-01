#!/bin/bash

set -e

echo "🚀 Deploying to PRODUCTION environment..."
echo "⚠️  WARNING: This will deploy to PRODUCTION!"
echo ""

# Confirmation prompt
read -p "Are you sure you want to deploy to PRODUCTION? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "❌ Deployment cancelled"
    exit 1
fi

# Load environment variables
if [ -f .env ]; then
    set -a
    source .env
    set +a
fi

# Validate required environment variables
if [ -z "$HCLOUD_API_TOKEN_PRODUCTION" ]; then
    echo "❌ Error: HCLOUD_API_TOKEN_PRODUCTION is not set"
    echo "Please set your production API token in .env file"
    exit 1
fi

if [ -z "$SSH_PUBLIC_KEY" ]; then
    echo "❌ Error: SSH_PUBLIC_KEY is not set"
    echo "Please set your SSH public key in .env file"
    exit 1
fi

# Install dependencies if needed
echo "📦 Installing Ansible dependencies..."
ansible-galaxy collection install -r requirements.yml --force

# Show what will be deployed
echo ""
echo "📋 Production deployment summary:"
echo "  - Environment: production"
echo "  - Master server: cax41"
echo "  - Worker nodes: 3x cax21"
echo "  - Network: 172.16.0.0/24"
echo ""

# Final confirmation
read -p "Proceed with production deployment? (yes/no): " final_confirm
if [ "$final_confirm" != "yes" ]; then
    echo "❌ Deployment cancelled"
    exit 1
fi

# Run deployment
echo "🏗️  Deploying infrastructure to production..."
ansible-playbook \
    -i inventories/production/hosts.yml \
    playbooks/infrastructure.yml \
    --extra-vars "environment=production" \
    -v

echo "✅ Production deployment completed successfully!"
echo ""
echo "📋 Next steps:"
echo "  1. Verify all resources in Hetzner Cloud console"
echo "  2. Run health checks on all servers"
echo "  3. Set up monitoring and alerting"
echo "  4. Configure backups"