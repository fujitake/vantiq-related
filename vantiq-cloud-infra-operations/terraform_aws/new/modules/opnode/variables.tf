
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

variable "basion_kubectl_version" {
  description = "install kubectl version"
  type        = string
  default     = "$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"
}

variable "basion_vpc_id" {
  description = "VPC ID"
  type        = string
  default     = null
}

variable "basion_subnet_id" {
  description = "VPC subnet id to allocate basion instance"
  type        = string
  default     = null
}

variable "worker_access_private_key" {
  description = "Private key for access eks worker node"
  type        = string
  default     = null
}

variable "basion_access_public_key_name" {
  description = "Public key for registering basion instance"
  type        = string
  default     = null
}

variable "basion_instance_type" {
  description = "Basion EC2 instance type"
  type        = string
  default     = null
}