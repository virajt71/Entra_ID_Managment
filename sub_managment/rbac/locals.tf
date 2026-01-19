# Improved RBAC configuration with fixes
locals {
  rbac_matrix = csvdecode(file("../rbac.csv"))

  environments = {
    dev = {
      key = "root/envs/dev/terraform.tfstate"
    }
    staging = {
      key = "root/envs/staging/terraform.tfstate"
    }
    prod = {
      key = "root/envs/prod/terraform.tfstate"
    }
  }

  # Expand CSV rows into a flat list of assignments
  rbac_assignments = flatten([
    for row in local.rbac_matrix : [
      for env in ["dev", "staging", "prod"] : {
        team        = row.Team
        environment = env
        roles       = split(" + ", row[title(env)]) # Dynamic column access
      }
      if row[title(env)] != "" && row[title(env)] != null # Skip empty assignments
    ]
  ])
}

