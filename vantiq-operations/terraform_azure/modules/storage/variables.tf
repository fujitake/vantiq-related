
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

variable "storage_account_name" {
  description = "name of storage account. must be unique in global."
  type = string
  default = null
}

variable "storage_account_subnet_id" {
  description = "id of the subnet to create the private endpoint"
  type = string
  default = null
}

variable "private_endpoint_vnet_ids" {
  description = "vnet for private DNS zone to be associated"
  type = list(string)
  default = []
}

variable "delete_after_days_since_modification_greater_than" {
  description = "days after which the blob should be deleted"
  type = number
  default = null
}
