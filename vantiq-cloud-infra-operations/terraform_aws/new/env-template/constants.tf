provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = local.region
}

terraform {
  required_version = ">= 1.1.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.10.0"
    }
  }
}

locals {
  tf_remote_backend = {
    bucket = "<INPUT-YOUR-BUCKET-NAME>"
    key    = "<INPUT-YOUR-KEY-PREFIX>"
    region = "<INPUT-YOUR-BUCKET-REGION>"
  }
}

###
###  common config(Custom setting)
###
locals {
  common_config = {
    cluster_name                  = "<INPUT-YOUR-CLUSTER-NAME>"
    cluster_version               = "1.22"
    basion_kubectl_version        = "1.22.15"
    env_name                      = "template"
    region                        = "<INPUT-YOUR-REGION>"
    worker_access_private_key     = "<INPUT-YOUR-SSH-PRIVATE-KEY-FILE-NAME>"
    worker_access_public_key_name = "<INPUT-YOUR-SSH-PUBLIC-KEY-FILE-NAME>"
    basion_access_public_key_name = "<INPUT-YOUR-SSH-PUBLIC-KEY-FILE-NAME>"
    basion_instance_type          = "t2.micro"
  }
}

###
###  network config(The following is custom setting)
###
locals {
  network_config = {
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
}

### 
### rds config
###
locals {
  rds_config = {
    db_name     = "keycloak"
    db_username = "keycloak"
    # db_password             = "password1234"
    db_password             = null
    db_instance_class       = "db.t3.medium"
    db_storage_size         = 100
    db_storage_type         = "gp2"
    postgres_engine_version = "12.7"
    keycloak_db_expose_port = 5432
  }
}

###
###  eks config
###
locals {
  eks_config = {
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
        node_workload_label = "compute"
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
        node_workload_label = "database"
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
        node_workload_label = "shared"
      },
      "grafana" = {
        ami_type       = "AL2_x86_64"
        instance_types = ["r5.xlarge"] # r5.xlarge x 1
        disk_size      = 40
        scaling_config = {
          desired_size = 1
          max_size     = 6
          min_size     = 0
        }
        node_workload_label = "influxdb"
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
        node_workload_label = "compute"
      }
    }
  }
}
