### Case by use local for terraform backend - start ###
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../10_network/terraform.tfstate"
  }
}
### Case by use local for terraform backend - end ###


# ## Case by use S3 Bucket for terraform backend - start ###
# terraform {
#   backend "s3" {
#     bucket = "<INPUT-YOUR-BUCKET-NAME>"
#     key    = "<INPUT-YOUR-KEY-PREFIX>/main.tfstate"
#     region = "<INPUT-YOUR-BUCKET-REGION>"
#   }
# }

# data "terraform_remote_state" "network" {
#   backend = "s3"
#   config = {
#     bucket = local.tf_remote_backend.bucket_name
#     key    = "${local.tf_remote_backend.key_prefix}/network.tfstate"
#     region = local.tf_remote_backend.region
#   }
# }
# ## Case by use S3 Bucket for terraform backend - end ###
