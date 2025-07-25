###
###  common config(Custom setting)
###
locals {
  common_config = {
    cluster_name                   = "<INPUT-YOUR-CLUSTER-NAME>"
    cluster_version                = "<INPUT-YOUR-CLUSTER-VERSION>"
    bastion_kubectl_version        = "<INPUT-YOUR-KUBECTL-VERSION>"
    env_name                       = "dev"
    region                         = "<INPUT-YOUR-REGION>"
    worker_access_private_key      = "<INPUT-YOUR-SSH-PRIVATE-KEY-FILE-NAME>"
    worker_access_public_key_name  = "<INPUT-YOUR-SSH-PUBLIC-KEY-FILE-NAME>"
    bastion_access_public_key_name = "<INPUT-YOUR-SSH-PUBLIC-KEY-FILE-NAME>"
    bastion_enabled                = true
    bastion_instance_type          = "t2.small"
    bastion_jdk_version            = "11"
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
        availability_zone = "${local.common_config.region}a"
      }
      "az-1" = {
        cidr_block        = "172.20.1.0/24"
        availability_zone = "${local.common_config.region}b"
      }
      # "az-2" = {
      #   cidr_block        = "172.20.2.0/24"
      #   availability_zone = "${local.common_config.region}d"
      # }
    }

    private_subnet_config = {
      "az-0" = {
        cidr_block        = "172.20.10.0/24"
        availability_zone = "${local.common_config.region}a"
      }
      "az-1" = {
        cidr_block        = "172.20.11.0/24"
        availability_zone = "${local.common_config.region}b"
      }
      # "az-2" = {
      #   cidr_block        = "172.20.12.0/24"
      #   availability_zone = "${local.common_config.region}d"
      # }
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
    db_instance_class       = "db.t3.micro"
    db_storage_size         = 20
    db_storage_type         = "gp2"
    postgres_engine_version = "17.5"
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
        ami_type           = "AL2023_x86_64_STANDARD"
        kubernetes_version = "${local.common_config.cluster_version}"
        instance_types     = ["c5.xlarge"]
        disk_size          = 40
        scaling_config = {
          desired_size = 1
          max_size     = 6
          min_size     = 0
        }
        node_workload_label = "compute"
      },
      "MongoDB" = {
        ami_type           = "AL2023_x86_64_STANDARD"
        kubernetes_version = "${local.common_config.cluster_version}"
        instance_types     = ["r5.xlarge"]
        disk_size          = 40
        scaling_config = {
          desired_size = 1
          max_size     = 6
          min_size     = 0
        }
        node_workload_label = "database"
      },
      "Keycloak" = {
        ami_type           = "AL2023_x86_64_STANDARD"
        kubernetes_version = "${local.common_config.cluster_version}"
        instance_types     = ["t3.medium"]
        disk_size          = 40
        scaling_config = {
          desired_size = 1
          max_size     = 6
          min_size     = 0
        }
        node_workload_label = "shared"
      },
      "Grafana" = {
        ami_type           = "AL2023_x86_64_STANDARD"
        kubernetes_version = "${local.common_config.cluster_version}"
        instance_types     = ["r5.xlarge"]
        disk_size          = 40
        scaling_config = {
          desired_size = 1
          max_size     = 6
          min_size     = 0
        }
        node_workload_label = "influxdb"
      },
      "Metrics" = {
        ami_type           = "AL2023_x86_64_STANDARD"
        kubernetes_version = "${local.common_config.cluster_version}"
        instance_types     = ["m5.xlarge"]
        disk_size          = 40
        scaling_config = {
          desired_size = 0
          max_size     = 6
          min_size     = 0
        }
        node_workload_label = "compute"
      },
      "Ai_assistant" = {
        ami_type           = "AL2023_x86_64_STANDARD"
        kubernetes_version = "${local.common_config.cluster_version}"
        instance_types     = ["c5.xlarge"]
        disk_size          = 40
        scaling_config = {
          desired_size = 1
          max_size     = 6
          min_size     = 0
        }
        node_workload_label = "orgCompute"
      },
    }
    single_az_node_list          = ["VANTIQ", "MongoDB", "Keycloak", "Grafana", "Metrics", "Ai_assistant"]
    sg_ids_allowed_ssh_to_worker = []
  }
  eks_addon_config = {
    ebs_csi_driver_enabled = true
  }
}