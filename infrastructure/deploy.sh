#!/bin/bash

# Azure deployment script for Drug Interaction Checker

set -e

# Variables
RESOURCE_GROUP="drug-interaction-rg"
LOCATION="eastus"
POSTGRES_ADMIN_PASSWORD=$(openssl rand -base64 32)

echo "Starting Azure deployment..."

# Create resource group
echo "Creating resource group..."
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# Deploy infrastructure using Bicep
echo "Deploying infrastructure..."
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file azure-deploy.bicep \
  --parameters postgresAdminPassword=$POSTGRES_ADMIN_PASSWORD

echo "Deployment completed!"
echo ""
echo "⚠️  IMPORTANT: Save these credentials securely!"
echo "PostgreSQL Admin Password: $POSTGRES_ADMIN_PASSWORD"
echo ""
echo "Next steps:"
echo "1. Add secrets to Key Vault (OpenAI API key, JWT key, etc.)"
echo "2. Build and push Docker image to ACR"
echo "3. Configure GitHub Actions secrets"
echo "4. Push to main branch to trigger deployment"