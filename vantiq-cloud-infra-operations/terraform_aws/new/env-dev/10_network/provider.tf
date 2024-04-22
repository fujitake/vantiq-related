terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.49.0"
    }
  }
}

provider "aws" {
  region                   = module.constants.common_config.region
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"
}
