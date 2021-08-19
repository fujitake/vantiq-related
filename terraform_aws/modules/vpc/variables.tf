variable "tags" {
  description = "Region to craete resources"
  type        = map(string)
  default     = null
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "vantiq_cluster"
}

variable "env_name" {
  description = "environment to be used in tags"
  type        = string
  default     = "dev"
}

variable "public_subnet_config" {
  description = "VPC public subnet config"
  type        = any
  default     = null
}

variable "private_subnet_config" {
  description = "VPC private subnet config"
  type        = any
  default     = null
}

variable "subnet_roles" {
  description = "Part of tags name for attach VPC subnet(k8s use deploy elb)"
  type = object({
    public  = string
    private = string
  })
}

variable "vpc_cidr_block" {
  description = "VPC cidr block"
  type        = string
}