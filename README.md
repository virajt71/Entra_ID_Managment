# Azure Infrastructure with Entra ID & RBAC Management

This Terraform project manages Azure infrastructure across multiple environments (Dev, Staging, Prod) with comprehensive identity and access management through automated user, group, and RBAC provisioning.

## Project Structure

```
.
├── envs/                          # Environment-specific infrastructure
│   ├── dev/
│   ├── staging/
│   └── prod/
├── modules/
│   ├── management/
│   │   ├── users-management/      # User provisioning from CSV
│   │   ├── groups-management/     # Azure AD group creation
│   │   └── rbac/                  # Role assignment management
│   ├── compute/
│   ├── network/
│   └── resource-group/
└── sub_managment/                 # Identity management orchestration
    ├── users/                     # User creation workflow
    ├── groups/                    # Group creation workflow
    └── rbac/                      # RBAC assignment workflow
```

## Identity & Access Management Flow

The IAM implementation follows a three-stage workflow with state dependencies:

### 1. User Management (`sub_managment/users/`)

**Purpose**: Creates Azure AD users from a CSV file.

**Input**: `sub_managment/users.csv`
```csv
given_name,surname,job_title,department,password,force_password_change
John,Smith,Senior DevOps Engineer,Infra,SecurePass123!,True
Jane,Doe,DevOps Engineer,Infra,SecurePass123!,True
```

**Module Logic** (`modules/management/users-management/`):
- Reads CSV file using Terraform's `csvdecode()` function
- Auto-detects company domain from Azure AD tenant if not provided
- Generates User Principal Names (UPNs) using format: `firstname_lastname@domain.com`
- Creates unique user keys for Terraform state management
- Groups users by department for downstream consumption

### 2. Group Management (`sub_managment/groups/`)

**Purpose**: Creates Azure AD security groups for each department and assigns users as members.

**Dependencies**: Reads from `users` terraform state via remote state data source.

**Module Logic** (`modules/management/groups-management/`):
- Consumes department list and user mappings from users terraform state
- Creates security groups with naming convention: `dept-{department_name}`
- Normalizes department names (lowercase, spaces to underscores)
- Assigns subscription owner as group owner
- Creates individual membership resources for each user-group combination

**Group Member Management**:
- Uses separate `azuread_group_member` resources to avoid conflicts
- Creates unique keys for each user-group combination
- Uses `object_id` instead of `id` for proper API compatibility
- Prevents duplicate memberships through Terraform state tracking

### 3. RBAC Management (`sub_managment/rbac/`)

**Purpose**: Assigns Azure RBAC roles to department groups across environments based on a role matrix.

**Input**: `sub_managment/rbac.csv`
```csv
Team,Dev,Staging,Prod
Infra,Contributor,Contributor,Reader + Contributor
Engineering,Contributor,Reader,Reader
Operations,Reader + Monitoring Contributor,Reader + Monitoring Contributor,Reader + Monitoring Contributor + Support Request Contributor
Quality Assurance,Reader,Reader,Reader
```

**Dependencies**:
- Reads resource group IDs from environment terraform states (dev/staging/prod)
- Looks up Azure AD groups by display name (must match department/team names)

**Module Logic** (`modules/management/rbac/`):
- Parses CSV to extract role assignments per team per environment
- Supports multiple roles per assignment using " + " delimiter
- Creates role assignments at resource group scope
- Maps teams to their corresponding Azure AD groups

**RBAC Assignment Logic**:
```hcl
# Flatten CSV into individual assignments
rbac_assignments = flatten([
  for row in rbac_matrix : [
    for env in ["dev", "staging", "prod"] : {
      team        = row.Team
      environment = env
      roles       = split(" + ", row[title(env)])
    }
  ]
])

# Example result:
# [
#   { team = "Infra", environment = "dev", roles = ["Contributor"] },
#   { team = "Infra", environment = "staging", roles = ["Contributor"] },
#   { team = "Infra", environment = "prod", roles = ["Reader", "Contributor"] },
#   ...
# ]
```

## Deployment Order

Due to state dependencies, deploy in this sequence:

```bash
# 1. Deploy infrastructure environments first
cd envs/dev && terraform init && terraform apply
cd envs/staging && terraform init && terraform apply
cd envs/prod && terraform init && terraform apply

# 2. Create users from CSV
cd sub_managment/users && terraform init && terraform apply

# 3. Create groups and assign users (depends on users state)
cd sub_managment/groups && terraform init && terraform apply

# 4. Assign RBAC roles (depends on groups and environment states)
cd sub_managment/rbac && terraform init && terraform apply
```

## State Management

The project uses Azure Storage backend for state management:

```hcl
backend "azurerm" {
  resource_group_name  = "tfstate-rg"
  storage_account_name = "tfstatenmdtm"
  container_name       = "tfstate"
  key                  = "root/sub_managment/{users|groups|rbac}/terraform.tfstate"
}
```

## License

MIT License - See LICENSE file for details.
