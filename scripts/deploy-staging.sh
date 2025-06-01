#!/bin/bash

set -e

echo "🚀 Deploying to STAGING environment..."

# Load environment variables
if [ -f .env ]; then
    set -a
    source .env
    set +a
fi

# Validate required environment variables
if [ -z "$HCLOUD_API_TOKEN_STAGING" ]; then
    echo "❌ Error: HCLOUD_API_TOKEN_STAGING is not set"
    echo "Please set your staging API token in .env file"
    exit 1
fi

if [ -z "$SSH_PUBLIC_KEY_RAO" ]; then
    echo "❌ Error: SSH_PUBLIC_KEY_RAO is not set"
    echo "Please set your SSH public key in .env file"
    exit 1
fi

# Install dependencies if needed
echo "📦 Installing Ansible dependencies..."
ansible-galaxy collection install -r requirements.yml --force

# Run deployment
echo "🏗️  Deploying infrastructure to staging..."
ansible-playbook \
    -i inventories/staging/hosts.yml \
    playbooks/infrastructure.yml \
    --extra-vars "environment=staging" \
    -v

echo "✅ Staging deployment completed successfully!"
echo ""
echo "📋 Next steps:"
echo "  1. Check your Hetzner Cloud console for created resources"
echo "  2. Wait for servers to be fully provisioned"
echo "  3. Run post-deployment setup if needed"