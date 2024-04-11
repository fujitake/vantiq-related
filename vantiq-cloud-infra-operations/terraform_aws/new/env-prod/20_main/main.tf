data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

locals {
  vpc_module_data              = data.terraform_remote_state.network.outputs.vpc_module_out
  sg_ids_allowed_ssh_to_worker = module.constants.common_config.bastion_enabled ? concat(module.constants.eks_config.sg_ids_allowed_ssh_to_worker, [module.opnode.bastion_ssh_allow_sg_id]) : module.constants.eks_config.sg_ids_allowed_ssh_to_worker
  addon_config = {
    kubernetes_version = module.constants.common_config.cluster_version
    resolve_conflicts  = "OVERWRITE"
    # additional_iam_policies = [] # arn lists
  }
  irsa_config = {
    create_kubernetes_namespace       = false
    create_kubernetes_service_account = false
    eks_oidc_provider                 = module.eks.oidc_provider
    eks_oidc_provider_arn             = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.eks.oidc_provider}"
    eks_oidc_issuer                   = module.eks.oidc_issuer
  }
  managed_node_group_config = {
    for node_group, conf in module.constants.eks_config.managed_node_group_config :
    node_group => contains(module.constants.eks_config.single_az_node_list, node_group) ?
    merge(conf, { subnet_ids = [local.vpc_module_data.private_subnet_ids[0]] }) :
    merge(conf, { subnet_ids = local.vpc_module_data.private_subnet_ids })
  }
}

module "constants" {
  source     = "../"
}

module "eks" {
  source             = "../../modules/eks"
  cluster_name       = "${module.constants.common_config.cluster_name}-${module.constants.common_config.env_name}"
  env_name           = module.constants.common_config.env_name
  vpc_id             = local.vpc_module_data.vpc_id
  public_subnet_ids  = local.vpc_module_data.public_subnet_ids
  private_subnet_ids = local.vpc_module_data.private_subnet_ids

  worker_access_ssh_key_name   = "../${module.constants.common_config.worker_access_public_key_name}"
  sg_ids_allowed_ssh_to_worker = local.sg_ids_allowed_ssh_to_worker

  cluster_version           = module.constants.common_config.cluster_version
  managed_node_group_config = local.managed_node_group_config
}

module "eks-addon-ebs-csi-driver" {
  source           = "../../modules/eks_addon/ebs_csi_driver"
  enabled          = module.constants.eks_addon_config.ebs_csi_driver_enabled
  cluster_eks_name = module.eks.cluster_eks_name
  addon_config     = local.addon_config
  irsa_config      = local.irsa_config
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
  worker_node_sg_id = module.eks.cluster_security_group_id

  # The following is custom setting
  db_instance_class       = module.constants.rds_config.db_instance_class
  db_storage_size         = module.constants.rds_config.db_storage_size
  db_storage_type         = module.constants.rds_config.db_storage_type
  postgres_engine_version = module.constants.rds_config.postgres_engine_version
}

module "opnode" {
  source       = "../../modules/opnode"
  enabled      = module.constants.common_config.bastion_enabled
  cluster_name = module.constants.common_config.cluster_name
  env_name     = module.constants.common_config.env_name

  bastion_jdk_version     = module.constants.common_config.bastion_jdk_version
  bastion_kubectl_version = module.constants.common_config.bastion_kubectl_version

  bastion_vpc_id        = local.vpc_module_data.vpc_id
  bastion_subnet_id     = local.vpc_module_data.public_subnet_ids[0]
  bastion_instance_type = module.constants.common_config.bastion_instance_type

  worker_access_private_key      = "../${module.constants.common_config.worker_access_private_key}"
  bastion_access_public_key_name = "../${module.constants.common_config.bastion_access_public_key_name}"
}
