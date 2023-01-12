##
##  common
##
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

##
## vnet
##
variable "vnet_address_cidr"{
  description = "CIDR of the VNET"
  type = list(string)
  default = ["10.0.0.0/8"]
}

variable "vnet_dns_servers" {
  description = "DNS server (optional)"
  type = list(string)
  default = null
}

##
##  snet
##
variable "snet_aks_node_address_cidr" {
  description = "CIDR of the private subnet"
  type = list(string)
  default = null
}

variable "snet_op_address_cidr" {
  description = "CIDR of the op subnet"
  type = list(string)
  default = null
}

variable "snet_aks_lb_address_cidr" {
  description = "CIDR of subnet to place aks load balancer"
  type = list(string)
  default = null
}

##
##  nsg
##
variable "snet_aks_allow_inbound_cidr" {
  description = "list of cidrs to allow inbound traffic from for aks node"
  type = list(string)
  default = ["10.0.0.0/8"]
}

variable "snet_aks_allow_outbound_ports" {
  description = "list of ports to allow output traffic from aks node"
  type = list(string)
  default = null
}

variable "snet_aks_allow_outbound_port" {
  description = "port to allow output traffic from aks node"
  type = string
  default = null
}


variable "snet_op_allow_inbound_cidr" {
  description = "list of cidrs to allow inbound traffic from for op node"
  type = list(string)
  default = ["10.0.0.0/8"]
}

variable "snet_op_allow_outbound_ports" {
  description = "list of ports to allow output traffic from o@"
  type = list(string)
  default = null
}

variable "snet_op_allow_outbound_port" {
  description = "port to allow output traffic from o@"
  type = string
  default = null
}


variable "snet_lb_allow_inbound_cidr" {
  description = "list of cidrs to allow inbound traffic from for load balancer"
  type = list(string)
  default = ["10.0.0.0/8"]
}
##
##  vnet-peering
##
variable "vnet_peering_remote_vnet_ids" {
  description = "list of vnet ids to link with VNET"
  type = list(string)
  default = []
}
##
##  Firewall
##
variable "firewall_ip" {
  description = "IP of firewall to use. If IP is set, then the gateway is set to FW, otherwise, default Internet GW is used."
  type = string
  default = null
}
