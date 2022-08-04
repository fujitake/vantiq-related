###
###  common config(Custom setting)
###
locals {
  cluster_name                  = "vantiq_cluster"
  cluster_version               = "1.21"
  basion_kubectl_version        = "1.21.14"
  env_name                      = "prod"
  region                        = "<INPUT-YOUR-REGION>"
  worker_access_private_key     = "<INPUT-YOUR-SSH-PRIVATE-KEY-FILE-NAME>"
  worker_access_public_key_name = "<INPUT-YOUR-SSH-PUBLIC-KEY-FILE-NAME>"
  basion_access_public_key_name = "<INPUT-YOUR-SSH-PUBLIC-KEY-FILE-NAME>"
  keycloak_db_expose_port       = 5432
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = local.region
}

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
  required_version = ">= 1.1.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.10.0"
    }
  }
}

# Case by use S3 Bucket for terraform backend
# terraform {
#   backend "s3" {
#     bucket = "<INPUT-YOUR-S3-BUCKET-NAME>"
#     key    = "tfstate/dev"
#     region = "<INPUT-YOUR-REGION>"
#   }
#   required_version = ">= 1.1.8"
#   required_providers {
#     aws = {
#       source = "hashicorp/aws"
#       version = ">= 4.10.0"
#     }
#   }
# }


module "vpc" {
  source       = "../modules/vpc"
  cluster_name = local.cluster_name
  env_name     = local.env_name
  subnet_roles = {
    public  = "elb"
    private = "internal-elb"
  }

  # The following is custom setting
  vpc_cidr_block = "172.20.0.0/16"

  public_subnet_config = {
    "az-0" = {
      cidr_block        = "172.20.0.0/24"
      availability_zone = "us-west-2a"
    }
    "az-1" = {
      cidr_block        = "172.20.1.0/24"
      availability_zone = "us-west-2b"
    }
    "az-2" = {
      cidr_block        = "172.20.2.0/24"
      availability_zone = "us-west-2c"
    }
  }

  private_subnet_config = {
    "az-0" = {
      cidr_block        = "172.20.10.0/24"
      availability_zone = "us-west-2a"
    }
    "az-1" = {
      cidr_block        = "172.20.11.0/24"
      availability_zone = "us-west-2b"
    }
    "az-2" = {
      cidr_block        = "172.20.12.0/24"
      availability_zone = "us-west-2c"
    }
  }
}


module "eks" {
  source             = "../modules/eks"
  cluster_name       = local.cluster_name
  env_name           = local.env_name
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

  worker_access_ssh_key_name = local.worker_access_public_key_name
  basion_ec2_sg_ids          = [module.opnode.basion_ssh_allow_sg_id]

  keycloak_db_expose_port = local.keycloak_db_expose_port
  keycloak_db_sg_id       = module.keycloak-db.keycloak_db_sg_id

  # The following is custom setting
  cluster_version = local.cluster_version

  managed_node_group_config = {
    "VANTIQ" = {
      ami_type       = "AL2_x86_64"
      instance_types = ["c5.xlarge"] # c5.xlarge x 3
      disk_size      = 40
      scaling_config = {
        desired_size = 3
        max_size     = 6
        min_size     = 0
      }
    },
    "MongoDB" = {
      ami_type       = "AL2_x86_64"
      instance_types = ["r5.xlarge"] # r5.xlarge x 3
      disk_size      = 40
      scaling_config = {
        desired_size = 3
        max_size     = 6
        min_size     = 0
      }
    },
    "keycloak" = {
      ami_type       = "AL2_x86_64"
      instance_types = ["m5.large"] # m5.large x 3
      disk_size      = 40
      scaling_config = {
        desired_size = 3
        max_size     = 6
        min_size     = 0
      }
    },
    "grafana" = {
      ami_type       = "AL2_x86_64"
      instance_types = ["r5.xlarge"] # r5.xlarge x 3
      disk_size      = 40
      scaling_config = {
        desired_size = 1
        max_size     = 6
        min_size     = 0
      }
    },
    "mertics" = {
      ami_type       = "AL2_x86_64"
      instance_types = ["m5.xlarge"] # m5.xlarge x 1
      disk_size      = 40
      scaling_config = {
        desired_size = 1
        max_size     = 6
        min_size     = 0
      }
    }
  }
}


module "keycloak-db" {
  source       = "../modules/rds-postgres"
  cluster_name = local.cluster_name
  env_name     = local.env_name

  db_vpc_id      = module.vpc.vpc_id
  db_subnet_ids  = module.vpc.private_subnet_ids
  db_expose_port = local.keycloak_db_expose_port
  db_name        = "keycloak"
  db_username    = "keycloak"
  db_password    = "password1234"

  #  Change this Security Group, if use Self Managed Node Group
  #  This value is managed node group
  worker_node_sg_id = module.eks.cluster_security_group_id

  # The following is custom setting
  db_instance_class       = "db.t3.medium"
  db_storage_size         = 100
  db_storage_type         = "gp2"
  postgres_engine_version = "12.7"
}


module "opnode" {
  source       = "../modules/opnode"
  cluster_name = local.cluster_name
  env_name     = local.env_name

  basion_kubectl_version = local.basion_kubectl_version

  basion_vpc_id        = module.vpc.vpc_id
  basion_subnet_id     = module.vpc.public_subnet_ids[0]
  basion_instance_type = "t2.micro"

  worker_access_private_key     = local.worker_access_private_key
  basion_access_public_key_name = local.basion_access_public_key_name
}
