### Case by use local for terraform backend - start ###

terraform {
  backend "local" {
    path = "terraform.tfstate"
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
#       key                  = "network.tfstate"
#     }
# }

### Case by use Azure Storage for terraform backend - end ###
