### Case by use local for terraform backend - start ###

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../01_network/terraform.tfstate"
  }
}

data "terraform_remote_state" "opnode" {
  backend = "local"
  config = {
    path = "../02_opnode/terraform.tfstate"
  }
}

### Case by use local for terraform backend - end ###


### Case by use Azure Storage for terraform backend - start ###

# # store the tf-state in blob.
# # Note: variables cannot be used inside "backend" defintion

# terraform {
#     backend "azurerm" {
#       resource_group_name  = "<INPUT-YOUR-RESOURCE-GROUP>"
#       storage_account_name = "<INPUT-YOUR-STORAGE-ACCOUNT>"
#       container_name       = "<INPUT-YOUR-CONTAINER-NAME>"
#       key                  = "main.tfstate"
#     }
# }

# data "terraform_remote_state" "network" {
#   backend = "azurerm"
#   config = {
#       resource_group_name  = module.constants.tf_remote_backend.resource_group_name
#       storage_account_name = module.constants.tf_remote_backend.storage_account_name
#       container_name       = module.constants.tf_remote_backend.container_name
#       key                  = "network.tfstate"
#   }
# }

# data "terraform_remote_state" "opnode" {
#   backend = "azurerm"
#   config = {
#       resource_group_name  = module.constants.tf_remote_backend.resource_group_name
#       storage_account_name = module.constants.tf_remote_backend.storage_account_name
#       container_name       = module.constants.tf_remote_backend.container_name
#       key                  = "opnode.tfstate"
#   }
# }

### Case by use Azure Storage for terraform backend - end ###
