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
### Case by use local for terraform backend - end ###

### Case by use S3 Bucket for terraform backend - start ###
# terraform {
#   backend "s3" {
#     bucket = "<INPUT-YOUR-BUCKET-NAME>"
#     key    = "<INPUT-YOUR-KEY-PREFIX>/basion.tfstate"
#     region = "<INPUT-YOUR-BUCKET-REGION>"
#   }
# }

# data "terraform_remote_state" "network" {
#   backend = "s3"
#   config = {
#     bucket = module.constants.tf_remote_backend.bucket_name
#     key    = "${module.constants.tf_remote_backend.key_prefix}/network.tfstate"
#     region = module.constants.tf_remote_backend.region
#   }
# }
### Case by use S3 Bucket for terraform backend - end ###

locals {
  vpc_module_data = data.terraform_remote_state.network.outputs.vpc_module_out
}

module "constants" {
  source     = "../"
  access_key = var.access_key
  secret_key = var.secret_key
}

module "opnode" {
  source       = "../../modules/opnode"
  cluster_name = module.constants.common_config.cluster_name
  env_name     = module.constants.common_config.env_name

  basion_kubectl_version = module.constants.common_config.basion_kubectl_version

  basion_vpc_id        = local.vpc_module_data.vpc_id
  basion_subnet_id     = local.vpc_module_data.public_subnet_ids[0]
  basion_instance_type = module.constants.common_config.basion_instance_type

  worker_access_private_key     = "../${module.constants.common_config.worker_access_private_key}"
  basion_access_public_key_name = "../${module.constants.common_config.basion_access_public_key_name}"
}

