#!/bin/bash

set -e

ENVIRONMENT=${1:-staging}

if [ "$ENVIRONMENT" != "staging" ] && [ "$ENVIRONMENT" != "production" ]; then
    echo "❌ Error: Invalid environment. Use 'staging' or 'production'"
    echo "Usage: $0 [staging|production]"
    exit 1
fi

echo "🔧 Running post-deployment configuration for $ENVIRONMENT..."

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Check if we have dynamic inventory from infrastructure deployment
DYNAMIC_INVENTORY="inventories/$ENVIRONMENT/dynamic_hosts.yml"
STATIC_INVENTORY="inventories/$ENVIRONMENT/hosts.yml"

if [ -f "$DYNAMIC_INVENTORY" ]; then
    echo "📋 Using dynamic inventory with actual server IPs"
    INVENTORY_FILE="$DYNAMIC_INVENTORY"
else
    echo "⚠️  Dynamic inventory not found. You may need to create it manually or run infrastructure deployment first."
    echo "📋 Using static inventory (you'll need to update server IPs manually)"
    INVENTORY_FILE="$STATIC_INVENTORY"
fi

echo "🚀 Running post-deployment tasks..."
echo "  - System updates and security hardening"
echo "  - Docker installation (for Kubernetes)"
echo "  - SSH security configuration"
echo "  - Automatic updates setup"
echo ""

# Run post-deployment playbook
ansible-playbook \
    -i "$INVENTORY_FILE" \
    playbooks/post-deployment.yml \
    --extra-vars "environment=$ENVIRONMENT" \
    -v

echo "✅ Post-deployment configuration completed for $ENVIRONMENT!"
echo ""
echo "📋 What was configured:"
echo "  ✅ System packages updated"
echo "  ✅ Docker installed and configured"
echo "  ✅ SSH security hardened"
echo "  ✅ fail2ban installed for intrusion prevention"
echo "  ✅ Automatic security updates enabled"
echo "  ✅ Swap file created (for smaller instances)"
echo ""
echo "🔗 Next steps:"
echo "  1. Verify all servers are accessible: ansible all -i $INVENTORY_FILE -m ping"
echo "  2. Install Kubernetes: (future playbook)"
echo "  3. Configure your Kubernetes cluster"