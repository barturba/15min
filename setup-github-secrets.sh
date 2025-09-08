#!/bin/bash

# Setup script for GitHub Actions secrets needed for Kamal deployment
# Run this script to set up all required secrets

set -e

echo "🔐 Setting up GitHub Actions secrets for Kamal deployment"
echo "======================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) is not installed. Please install it first:${NC}"
    echo "   https://cli.github.com/"
    exit 1
fi

# Check if logged in to GitHub
if ! gh auth status &> /dev/null; then
    echo -e "${RED}❌ Not logged in to GitHub CLI. Please run:${NC}"
    echo "   gh auth login"
    exit 1
fi

echo -e "${BLUE}📋 Required secrets for Kamal deployment:${NC}"
echo "   • KAMAL_SSH_PRIVATE_KEY: SSH private key for accessing the server"
echo "   • KAMAL_HOST: Server IP address (your-server-ip)"
echo "   • KAMAL_REGISTRY_PASSWORD: Docker Hub password"
echo "   • RAILS_MASTER_KEY: Rails master key for production"
echo ""

# Step 1: Generate SSH key pair for GitHub Actions
echo -e "${BLUE}🔑 Step 1: Generating SSH key pair for GitHub Actions${NC}"
SSH_KEY_FILE="github-actions-key"
if [ ! -f "$SSH_KEY_FILE" ]; then
    ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_FILE" -N "" -C "github-actions@15min"
    echo -e "${GREEN}✅ SSH key pair generated:${NC}"
    echo "   Private key: $SSH_KEY_FILE"
    echo "   Public key: $SSH_KEY_FILE.pub"
else
    echo -e "${YELLOW}⚠️  SSH key pair already exists. Using existing keys.${NC}"
fi

# Step 2: Set KAMAL_HOST
echo ""
echo -e "${BLUE}🌐 Step 2: Setting KAMAL_HOST secret${NC}"
gh secret set KAMAL_HOST --body "your-server-ip"
echo -e "${GREEN}✅ KAMAL_HOST secret set${NC}"

# Step 3: Set SSH private key
echo ""
echo -e "${BLUE}🔐 Step 3: Setting KAMAL_SSH_PRIVATE_KEY secret${NC}"
gh secret set KAMAL_SSH_PRIVATE_KEY --body "$(cat $SSH_KEY_FILE)"
echo -e "${GREEN}✅ KAMAL_SSH_PRIVATE_KEY secret set${NC}"

# Step 4: Set Docker Hub password
echo ""
echo -e "${BLUE}🐳 Step 4: Setting KAMAL_REGISTRY_PASSWORD secret${NC}"
echo -e "${YELLOW}Please enter your Docker Hub password/token:${NC}"
read -s DOCKER_PASSWORD
gh secret set KAMAL_REGISTRY_PASSWORD --body "$DOCKER_PASSWORD"
echo -e "${GREEN}✅ KAMAL_REGISTRY_PASSWORD secret set${NC}"

# Step 5: Set Rails master key
echo ""
echo -e "${BLUE}🔑 Step 5: Setting RAILS_MASTER_KEY secret${NC}"
if [ -f "config/master.key" ]; then
    echo -e "${GREEN}Found config/master.key locally${NC}"
    gh secret set RAILS_MASTER_KEY --body "$(cat config/master.key)"
    echo -e "${GREEN}✅ RAILS_MASTER_KEY secret set from local file${NC}"
else
    echo -e "${YELLOW}⚠️  config/master.key not found locally${NC}"
    echo -e "${YELLOW}Please enter your Rails master key:${NC}"
    read -s RAILS_MASTER_KEY
    gh secret set RAILS_MASTER_KEY --body "$RAILS_MASTER_KEY"
    echo -e "${GREEN}✅ RAILS_MASTER_KEY secret set${NC}"
fi

# Step 6: Instructions for server setup
echo ""
echo -e "${BLUE}🚀 Step 6: Server Setup Instructions${NC}"
echo "Copy the following public key to your server's ~/.ssh/authorized_keys:"
echo ""
echo -e "${GREEN}$(cat ${SSH_KEY_FILE}.pub)${NC}"
echo ""
echo -e "${YELLOW}Run this on your server (your-server-ip):${NC}"
echo "   echo '$(cat ${SSH_KEY_FILE}.pub)' >> ~/.ssh/authorized_keys"
echo "   chmod 600 ~/.ssh/authorized_keys"
echo ""

# Step 7: Test the setup
echo -e "${BLUE}🧪 Step 7: Testing the setup${NC}"
echo -e "${YELLOW}Do you want to test the SSH connection now? (y/n)${NC}"
read -n 1 TEST_SSH
echo ""
if [[ $TEST_SSH =~ ^[Yy]$ ]]; then
    echo "Testing SSH connection..."
    if ssh -i "$SSH_KEY_FILE" -o StrictHostKeyChecking=no -o ConnectTimeout=10 root@your-server-ip "echo 'SSH connection successful'"; then
        echo -e "${GREEN}✅ SSH connection test passed${NC}"
    else
        echo -e "${RED}❌ SSH connection test failed${NC}"
        echo -e "${YELLOW}Make sure to add the public key to the server's authorized_keys${NC}"
    fi
fi

# Cleanup
echo ""
echo -e "${BLUE}🧹 Cleaning up temporary files${NC}"
rm -f "$SSH_KEY_FILE" "$SSH_KEY_FILE.pub"
echo -e "${GREEN}✅ Temporary SSH keys cleaned up${NC}"

echo ""
echo -e "${GREEN}🎉 All GitHub secrets have been set up!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Make sure the public key is added to the server's authorized_keys"
echo "2. Test the CI/CD pipeline by pushing a commit to main"
echo "3. Monitor the GitHub Actions workflow for the deploy job"
echo ""
echo -e "${YELLOW}To test manually, you can run:${NC}"
echo "   gh workflow run CI --ref main"
