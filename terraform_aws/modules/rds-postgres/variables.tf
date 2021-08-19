variable "tags" {
  description = "Region to craete resources"
  type        = map(string)
  default     = null
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = null
}

variable "env_name" {
  description = "environment to be used in tags"
  type        = string
  default     = null
}

variable "worker_node_sg_id" {
  description = "Worker node security group id to allow ssh from basion to worker nodes"
  type        = string
  default     = null
}

variable "db_vpc_id" {
  description = "VPC ID to allocate keycloak db instance"
  type        = string
  default     = null
}

variable "db_subnet_ids" {
  description = "VPC subnet ids to allocate keycloak db instance"
  type        = list(string)
  default     = null
}

variable "db_instance_class" {
  description = "keycloak db instance class"
  type        = string
  default     = null
}

variable "db_storage_size" {
  description = "keycloak db storage size"
  type        = number
  default     = null
}

variable "db_storage_type" {
  description = "keycloak db storage type"
  type        = string
  default     = null
}

variable "db_expose_port" {
  description = "keycloak db expose port"
  type        = number
  default     = null
}

variable "postgres_engine_version" {
  description = "keycloak db (postgres) engine version"
  type        = string
  default     = null
}

