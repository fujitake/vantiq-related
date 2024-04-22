module "constants" {
  source     = "../"
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
