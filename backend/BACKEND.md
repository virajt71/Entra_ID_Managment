# Backend Configuration Documentation
# ===================================

## Overview
Terraform state files for this project are stored in Azure Storage Backend to support:
- Multi-environment isolation (dev, staging, prod)
- Remote state sharing between sub-components (users → groups → rbac)
- Team collaboration and locking

## Setup Instructions

### 1. Create Azure Storage Account for Terraform State
```bash
# Set variables
RG_NAME="tfstate-rg"
SA_NAME="tfstate$(date +%s | md5sum | head -c 8)"  # Globally unique suffix
LOCATION="northeurope"
CONTAINER="tfstate"

# Create resource group
az group create --name $RG_NAME --location $LOCATION

# Create storage account
az storage account create \
  --resource-group $RG_NAME \
  --name $SA_NAME \
  --sku Standard_LRS \
  --kind StorageV2

# Create blob container
az storage container create \
  --name $CONTAINER \
  --account-name $SA_NAME

# Enable versioning and soft delete (for recovery)
az storage account blob-service-properties update \
  --account-name $SA_NAME \
  --enable-change-feed true \
  --enable-delete-retention true \
  --delete-retention-days 7 \
  --enable-restore-policy true
```

### 2. Configure Backend for Each Component
Update `backend/backend.hcl` with your storage account name, then initialize:

```bash
# For each directory (backend, envs/dev, envs/staging, envs/prod, sub_managment/users|groups|rbac):
cd <component_directory>
terraform init -backend-config=../../backend/backend.hcl
```

### 3. Backend Configuration Files
Each `providers.tf` should reference `backend.hcl`:

```hcl
terraform {
  # ... required_providers ...
  
  backend "azurerm" {}  # Will be configured via -backend-config during init
}
```

## State Key Naming Convention
```
tfstate/<scope>/<component>/terraform.tfstate

Examples:
- root/backend/terraform.tfstate
- root/envs/dev/terraform.tfstate
- root/envs/staging/terraform.tfstate
- root/envs/prod/terraform.tfstate
- root/sub_managment/users/terraform.tfstate
- root/sub_managment/groups/terraform.tfstate
- root/sub_managment/rbac/terraform.tfstate
```

## Security Best Practices
1. **Encryption**: Azure Storage encrypts all data at rest by default
2. **Access Control**: Use Azure RBAC to restrict who can access the storage account
3. **Network Security**: Enable storage account firewall to restrict network access
4. **State Locking**: Azure Storage backend automatically provides state locking
5. **Versioning**: Enable blob versioning for state recovery capability
6. **Audit Logging**: Enable Azure Activity Log and Storage Account diagnostics

## Troubleshooting
- If init fails with authentication error, ensure Service Principal has `Storage Blob Data Contributor` role on the storage account
- To migrate state from local to remote: `terraform init` with new backend config and answer "yes" to migration prompt
- To view state file: `terraform state show` or `az storage blob download --account-name <name> --container-name tfstate --name <key> --file -`
