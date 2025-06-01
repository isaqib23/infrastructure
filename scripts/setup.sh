#!/bin/bash

set -e

echo "🚀 Setting up Hetzner Cloud Infrastructure Environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  .env file not found. Creating from template...${NC}"
    if [ -f .env.example ]; then
        cp .env.example .env
        echo -e "${GREEN}✅ Created .env file from .env.example${NC}"
        echo -e "${YELLOW}📝 Please edit .env file with your actual values before proceeding${NC}"
    else
        echo -e "${RED}❌ .env.example file not found${NC}"
        exit 1
    fi
fi

# Load environment variables
if [ -f .env ]; then
    echo "📄 Loading environment variables..."
    # Use set -a to automatically export variables, then source the file
    set -a
    source .env
    set +a
fi

# Check if Ansible is installed
if ! command -v ansible &> /dev/null; then
    echo -e "${YELLOW}📦 Ansible not found. Installing...${NC}"

    # Check if pip3 is available
    if command -v pip3 &> /dev/null; then
        pip3 install ansible
    elif command -v pip &> /dev/null; then
        pip install ansible
    else
        echo -e "${RED}❌ pip/pip3 not found. Please install Python and pip first${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Ansible installed successfully${NC}"
else
    echo -e "${GREEN}✅ Ansible is already installed$(NC)"
fi

# Install required Ansible collections
echo "📦 Installing required Ansible collections..."
ansible-galaxy collection install -r requirements.yml --force

echo -e "${GREEN}✅ Collections installed successfully${NC}"

# Create necessary directories
echo "📁 Creating directory structure..."
mkdir -p {inventories/{staging,production}/{group_vars,host_vars},roles,playbooks,scripts}

# Validate environment setup
echo "🔍 Validating environment setup..."

# Check for required environment variables
REQUIRED_VARS=("SSH_PUBLIC_KEY_RAO")
MISSING_VARS=()

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        MISSING_VARS+=("$var")
    fi
done

# Check for at least one additional team member SSH key
TEAM_SSH_FOUND=false
for var in SSH_PUBLIC_KEY_SP; do
    if [ -n "${!var}" ]; then
        TEAM_SSH_FOUND=true
        break
    fi
done

if [ "$TEAM_SSH_FOUND" = false ]; then
    echo -e "${YELLOW}⚠️  Warning: No additional team SSH keys found. Consider adding SSH_PUBLIC_KEY_DEVOPS or SSH_PUBLIC_KEY_LEAD${NC}"
fi

# Check for at least one API token
if [ -z "$HCLOUD_API_TOKEN_STAGING" ] && [ -z "$HCLOUD_API_TOKEN_PRODUCTION" ]; then
    MISSING_VARS+=("HCLOUD_API_TOKEN_STAGING or HCLOUD_API_TOKEN_PRODUCTION")
fi

if [ ${#MISSING_VARS[@]} -ne 0 ]; then
    echo -e "${RED}❌ Missing required environment variables:${NC}"
    for var in "${MISSING_VARS[@]}"; do
        echo -e "${RED}  - $var${NC}"
    done
    echo -e "${YELLOW}📝 Please update your .env file with the missing values${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Environment validation passed${NC}"

# Make scripts executable
echo "🔧 Making scripts executable..."
chmod +x scripts/*.sh

echo ""
echo -e "${GREEN}🎉 Setup completed successfully!${NC}"
echo ""
echo "📋 Next steps:"
echo "  1. Review and update .env file with your actual values"
echo "  2. Deploy to staging: ./scripts/deploy-staging.sh"
echo "  3. Deploy to production: ./scripts/deploy-production.sh"
echo ""
echo "🔗 Useful commands:"
echo "  - Deploy staging: ./scripts/deploy-staging.sh"
echo "  - Deploy production: ./scripts/deploy-production.sh"
echo "  - Cleanup staging: ./scripts/cleanup.sh staging"
echo "  - Cleanup production: ./scripts/cleanup.sh production"