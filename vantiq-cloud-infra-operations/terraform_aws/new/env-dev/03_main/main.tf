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

data "terraform_remote_state" "basion" {
  backend = "local"
  config = {
    path = "../02_basion/terraform.tfstate"
  }
}
### Case by use local for terraform backend - end ###

### Case by use S3 Bucket for terraform backend - start ###
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
#     bucket = module.constants.tf_remote_backend.bucket_name
#     key    = "${module.constants.tf_remote_backend.key_prefix}/network.tfstate"
#     region = module.constants.tf_remote_backend.region
#   }
# }

# data "terraform_remote_state" "basion" {
#   backend = "s3"
#   config = {
#     bucket = module.constants.tf_remote_backend.bucket_name
#     key    = "${module.constants.tf_remote_backend.key_prefix}/basion.tfstate"
#     region = module.constants.tf_remote_backend.region
#   }
# }
### Case by use S3 Bucket for terraform backend - end ###

locals {
  vpc_module_data        = data.terraform_remote_state.network.outputs.vpc_module_out
  basion_ssh_allow_sg_id = data.terraform_remote_state.basion.outputs.basion_ssh_allow_sg_id
}

module "constants" {
  source     = "../"
  access_key = var.access_key
  secret_key = var.secret_key
}

module "eks" {
  source             = "../../modules/eks"
  cluster_name       = "${module.constants.common_config.cluster_name}-${module.constants.common_config.env_name}"
  env_name           = module.constants.common_config.env_name
  vpc_id             = local.vpc_module_data.vpc_id
  public_subnet_ids  = local.vpc_module_data.public_subnet_ids
  private_subnet_ids = local.vpc_module_data.private_subnet_ids

  worker_access_ssh_key_name = "../${module.constants.common_config.worker_access_public_key_name}"
  basion_ec2_sg_ids          = [local.basion_ssh_allow_sg_id]

  # The following is custom setting
  cluster_version = module.constants.common_config.cluster_version

  managed_node_group_config = module.constants.eks_config.managed_node_group_config
}


module "keycloak-db" {
  source       = "../../modules/rds-postgres"
  cluster_name = module.constants.common_config.cluster_name
  env_name     = module.constants.common_config.env_name

  db_vpc_id      = local.vpc_module_data.vpc_id
  db_subnet_ids  = local.vpc_module_data.private_subnet_ids
  db_expose_port = module.constants.rds_config.keycloak_db_expose_port
  db_name        = module.constants.rds_config.db_name
  db_username    = module.constants.rds_config.db_username
  db_password    = module.constants.rds_config.db_password

  #  Change this Security Group, if use Self Managed Node Group
  #  This value is managed node group
  worker_node_sg_id = local.basion_ssh_allow_sg_id

  # The following is custom setting
  db_instance_class       = module.constants.rds_config.db_instance_class
  db_storage_size         = module.constants.rds_config.db_storage_size
  db_storage_type         = module.constants.rds_config.db_storage_type
  postgres_engine_version = module.constants.rds_config.postgres_engine_version
}

