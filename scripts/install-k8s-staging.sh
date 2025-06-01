#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🚀 Installing Kubernetes on Staging Environment"
echo "================================================="

# Check if infrastructure is deployed
if ! ansible-inventory -i "$PROJECT_ROOT/inventories/staging/hosts.yml" --list > /dev/null 2>&1; then
    echo "❌ Staging infrastructure not found. Please deploy infrastructure first."
    echo "Run: ./scripts/deploy-staging.sh"
    exit 1
fi

# Verify nodes are accessible
echo "📡 Verifying node connectivity..."
ansible -i "$PROJECT_ROOT/inventories/staging/k8s-hosts.yml" all -m ping --private-key ~/.ssh/id_rsa

# Install Kubernetes using Kubespray
echo "🔧 Installing Kubernetes cluster..."
cd "$PROJECT_ROOT/kubespray"

ansible-playbook -i "../inventories/staging/k8s-hosts.yml" \
    --become \
    --become-user=root \
    --private-key ~/.ssh/id_rsa \
    -e @../inventories/staging/group_vars/all/k8s-cluster.yml \
    cluster.yml

echo "📋 Setting up kubeconfig..."
mkdir -p ~/.kube
scp -i ~/.ssh/id_rsa root@$(grep -A1 "staging-master-1:" ../inventories/staging/k8s-hosts.yml | grep ansible_host | cut -d' ' -f6):/etc/kubernetes/admin.conf ~/.kube/config-staging
chmod 600 ~/.kube/config-staging

echo "🔐 Applying Hetzner Cloud integration..."
cd "$PROJECT_ROOT"
ansible-playbook -i "inventories/staging/k8s-hosts.yml" \
    --private-key ~/.ssh/id_rsa \
    playbooks/k8s-post-install.yml \
    -e environment=staging

echo "✅ Staging Kubernetes cluster installed successfully!"
echo ""
echo "To use the cluster:"
echo "export KUBECONFIG=~/.kube/config-staging"
echo "kubectl get nodes"