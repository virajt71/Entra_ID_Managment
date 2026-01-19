# Resource Group
module "resource_group" {
  source = "../../modules/resource-group"

  name     = "${local.name_prefix}-rg"
  location = local.location
  tags     = local.common_tags
}

# # Network
# module "network" {
#   source = "../../modules/network"

#   name                = "${local.name_prefix}-vnet"
#   location            = local.location
#   resource_group_name = module.resource_group.name

#   address_space = ["10.0.0.0/16"]

#   subnets = {
#     web = {
#       address_prefixes = ["10.0.1.0/24"]
#     }
#   }

#   public_ips = {
#     web = {
#       allocation_method = "Static"
#       sku               = "Standard"
#     }
#   }

#   network_security_groups = {
#     web = {
#       security_rules = [
#         {
#           name                       = "SSH"
#           priority                   = 100
#           direction                  = "Inbound"
#           access                     = "Allow"
#           protocol                   = "Tcp"
#           source_port_range          = "*"
#           destination_port_range     = "22"
#           source_address_prefix      = "*"
#           destination_address_prefix = "*"
#         },
#         {
#           name                       = "HTTP"
#           priority                   = 200
#           direction                  = "Inbound"
#           access                     = "Allow"
#           protocol                   = "Tcp"
#           source_port_range          = "*"
#           destination_port_range     = "80"
#           source_address_prefix      = "*"
#           destination_address_prefix = "*"
#         }
#       ]
#     }
#   }

#   network_interfaces = {
#     web = {
#       subnet_key                    = "web"
#       private_ip_address_allocation = "Dynamic"
#       public_ip_key                 = "web"
#     }
#   }

#   nic_nsg_associations = {
#     web = {
#       nic_key = "web"
#       nsg_key = "web"
#     }
#   }

#   tags = local.common_tags
# }

# # Compute
# module "compute" {
#   source = "../../../modules/compute"

#   name                  = "${local.name_prefix}-vm"
#   location              = local.location
#   resource_group_name   = module.resource_group.name
#   resource_group_id     = module.resource_group.id
#   network_interface_ids = module.network.nic_ids

#   virtual_machines = {
#     web = {
#       size                            = "Standard_B2s"
#       nic_key                         = "web"
#       admin_username                  = "azureuser"
#       disable_password_authentication = false # Enable password authentication
#       admin_password                  = null  # Will use generated password

#       os_disk = {
#         caching              = "ReadWrite"
#         storage_account_type = "Premium_LRS"
#         disk_size_gb         = 64
#       }

#       source_image = {
#         publisher = "Canonical"
#         offer     = "0001-com-ubuntu-server-jammy"
#         sku       = "22_04-lts-gen2"
#         version   = "latest"
#       }

#       tags = local.common_tags
#     }
#   }

#   generate_ssh_key        = true # Generate SSH keys
#   generate_admin_password = true # Generate admin passwords

#   tags = local.common_tags
# }
