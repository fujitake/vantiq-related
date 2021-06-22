
variable "tags" {
  description = "Region to craete resources"
  type = map(string)
  default = null
}

variable "vantiq_cluster_name" {
  description = "vantiq cluster name to be used in suffix of the resource name"
  type = string
  default = null
}

variable "location"{
  description = "Region to craete resources"
  type = string
  default = null
}

variable "resource_group_name"{
  description = "Resource Group to craete resources"
  type = string
  default = null
}


variable "opnode_host_name"{
  description = "Hostname of the VM"
  type = string
  default = null
}
variable "opnode_user_name"{
  description = "Login user name for opnode VM"
  type = string
  default = null
}
variable "opnode_password"{
  description = "password for opnode VM"
  type = string
  default = null
}
variable "opnode_vm_size" {
  description = "spec of opnode VM"
  type = string
  default = "Standard_B2s"
}
variable "ssh_access_enabled" {
  description = "whether ssh access is required. true: ssh, false: password"
  type = bool
  default = true
}
variable "ssh_public_key" {
  description = "public key for ssh login"
  type = string
  default = null
}
variable "ssh_private_key_aks_node" {
  description = "public key to use to connect to aks node"
  type = string
  default = null
}

variable "opnode_subnet_id" {
  description = "subnet for opnode. either public subnet, or gateway subnet should be specified"
  type = string
  default = null
}

variable "public_ip_enabled" {
  description = "whether to temporarily allow access via public IP"
  type = bool
  default = false
}
variable "domain_name_label" {
  description = "domain label for public IP"
  type = string
  default = null
}
variable "vm_backup_enabled" {
  description = "enable weekly backup of opnode"
  type = bool
  default = false
}
