
variable "tags" {
  description = "Region to craete resources"
  type        = map(string)
  default     = null
}

variable "vantiq_cluster_name" {
  description = "vantiq cluster name to be used in suffix of the resource name"
  type        = string
  default     = null
}

variable "location" {
  description = "Region to craete resources"
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "Resource Group to craete resources"
  type        = string
  default     = null
}

variable "db_server_name" {
  description = "db server name. must be unique globally. alphanumeric only"
  type        = string
  default     = null
}

variable "private_endpoint_vnet_ids" {
  description = "vnet for private DNS zone to be associated"
  type        = list(string)
  default     = null
}

variable "private_subnet_id" {
  description = "subnet in which postgres server end point should be set up  "
  type        = string
  default     = null
}

variable "geo_redundant_backup_enabled" {
  description = "whether to enable geo redundant backup enabled"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "whether to make the db server avaialble as public"
  type        = bool
  default     = false
}
