#!/bin/bash

set -e

# Default to staging if no environment specified
ENVIRONMENT=${1:-staging}

if [ "$ENVIRONMENT" != "staging" ] && [ "$ENVIRONMENT" != "production" ]; then
    echo "❌ Error: Invalid environment. Use 'staging' or 'production'"
    echo "Usage: $0 [staging|production]"
    exit 1
fi

echo "🗑️  Cleaning up $ENVIRONMENT environment..."

if [ "$ENVIRONMENT" = "production" ]; then
    echo "⚠️  WARNING: This will DESTROY all PRODUCTION resources!"
    echo ""
    read -p "Are you ABSOLUTELY sure you want to destroy PRODUCTION? (type 'DELETE PRODUCTION'): " confirm
    if [ "$confirm" != "DELETE PRODUCTION" ]; then
        echo "❌ Cleanup cancelled"
        exit 1
    fi
else
    echo "This will destroy all staging resources."
    read -p "Are you sure? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "❌ Cleanup cancelled"
        exit 1
    fi
fi

# Load environment variables
if [ -f .env ]; then
    set -a
    source .env
    set +a
fi

# Set the appropriate API token variable
if [ "$ENVIRONMENT" = "production" ]; then
    if [ -z "$HCLOUD_API_TOKEN_PRODUCTION" ]; then
        echo "❌ Error: HCLOUD_API_TOKEN_PRODUCTION is not set"
        exit 1
    fi
    export HCLOUD_API_TOKEN="$HCLOUD_API_TOKEN_PRODUCTION"
else
    if [ -z "$HCLOUD_API_TOKEN_STAGING" ]; then
        echo "❌ Error: HCLOUD_API_TOKEN_STAGING is not set"
        exit 1
    fi
    export HCLOUD_API_TOKEN="$HCLOUD_API_TOKEN_STAGING"
fi

# Run cleanup
echo "🧹 Destroying $ENVIRONMENT infrastructure..."
ansible-playbook \
    -i "inventories/$ENVIRONMENT/hosts.yml" \
    playbooks/cleanup.yml \
    --extra-vars "deploy_environment=$ENVIRONMENT" \
    --extra-vars "hcloud_api_token=$HCLOUD_API_TOKEN" \
    -v

echo "✅ $ENVIRONMENT environment cleanup completed!"