variable "tags" {
  description = "Region to craete resources"
  type        = map(string)
  default     = null
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "env_name" {
  description = "environment to be used in tags"
  type        = string
  default     = "dev"
}

variable "cluster_version" {
  description = "EKS Cluster Version"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = null
}

variable "public_subnet_ids" {
  description = "VPC public subnet id"
  type        = list(string)
  default     = null
}

variable "private_subnet_ids" {
  description = "VPC private subnet id"
  type        = list(string)
  default     = null
}

variable "managed_node_group_config" {
  description = "managed node group instances config"
  type        = any
  default     = {}
}

variable "worker_access_ssh_key_name" {
  description = "ssh key name to access worker nodes from basion ec2 instance"
  type        = string
  default     = null
}

variable "sg_ids_allowed_ssh_to_worker" {
  description = "security group ids allowed ssh access to worker node"
  type        = list(string)
  default     = null
}
