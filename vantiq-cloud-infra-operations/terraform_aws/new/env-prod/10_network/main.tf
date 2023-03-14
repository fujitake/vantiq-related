provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = module.constants.common_config.region
}

### Case by use local for terraform backend - start ###
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

### Case by use local for terraform backend - end ###

### Case by use S3 Bucket for terraform backend - start ###
# terraform {
#   backend "s3" {
#     bucket = "<INPUT-YOUR-BUCKET-NAME>"
#     key    = "<INPUT-YOUR-KEY-PREFIX>/network.tfstate"
#     region = "<INPUT-YOUR-BUCKET-REGION>"
#   }
# }
### Case by use S3 Bucket for terraform backend - end ###

module "constants" {
  source     = "../"
  access_key = var.access_key
  secret_key = var.secret_key
}

module "vpc" {
  source       = "../../modules/vpc"
  cluster_name = "${module.constants.common_config.cluster_name}-${module.constants.common_config.env_name}"
  env_name     = module.constants.common_config.env_name
  subnet_roles = {
    public  = "elb"
    private = "internal-elb"
  }

  vpc_cidr_block = module.constants.network_config.vpc_cidr_block

  public_subnet_config = module.constants.network_config.public_subnet_config

  private_subnet_config = module.constants.network_config.private_subnet_config
}
