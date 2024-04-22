
variable "tags" {
  description = "Region to craete resources"
  type        = map(string)
  default     = null
}

variable "aks_cluster_name" {
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

variable "private_cluster_enabled" {
  description = "Whether API endpoit should be private. True = private only, false = public only"
  type        = bool
  default     = false
}

variable "kubernetes_version" {
  description = "kubernetes version"
  type        = string
  default     = null
}

# network profile
variable "dns_service_ip" {
  description = "DNS service IP for cluster. This IP must be within the range of Service CIDR"
  type        = string
  default     = null
}

variable "load_balancer_sku" {
  description = "load balacer sku. must be standard or higher"
  type        = string
  default     = "standard"
}
variable "network_plugin" {
  description = "network plugin. azure or kubenet"
  type        = string
  default     = "azure"
}
variable "network_policy" {
  description = "network policy. calico or azure"
  type        = string
  default     = "azure"
}
variable "outbound_type" {
  description = "outbound type of routing method. loadBalancer or userDefinedRouting"
  type        = string
  default     = "loadBalancer"
}
variable "pod_cidr" {
  description = "The CIDR to use for pod IP addresses. This field can only be set when network_plugin is set to kubenet."
  type        = string
  default     = null
}
variable "service_cidr" {
  description = "The Network Range used by the Kubernetes service."
  type        = string
  default     = null
}



# loadbalancer profile
variable "managed_outbound_ip_count" {
  description = "Count of desired managed outbound IPs for the cluster load balancer. Must be in the range of [1, 100]."
  type        = number
  default     = null
}
variable "outbound_ip_prefix_ids" {
  description = "The ID of the outbound Public IP Address Prefixes which should be used for the cluster load balancer."
  type        = list(string)
  default     = null
}
variable "outbound_ip_address_ids" {
  description = "The ID of the Public IP Addresses which should be used for outbound communication for the cluster load balancer."
  type        = list(string)
  default     = null
}


# linux profile
variable "admin_username" {
  description = "The Network Range used by the Kubernetes service."
  type        = string
  default     = null
}
variable "ssh_key" {
  description = "public key for ssh login"
  type        = string
  default     = null
}

# node pool
variable "availability_zones" {
  description = "availability zones for aks control plane and node pool"
  type        = list(number)
  default     = [1, 2, 3]
}

variable "vantiq_node_pool_vm_size" {
  description = "VM size for vantiq node pool"
  type        = string
  default     = null
}

variable "vantiq_node_pool_node_count" {
  description = "VM count for vantiq node pool"
  type        = number
  default     = 1
}
variable "vantiq_node_pool_node_ephemeral_os_disk" {
  description = "Use of Ephemeral OS Disk for vantiq node pool"
  type        = bool
  default     = true
}

variable "mongodb_node_pool_vm_size" {
  description = "VM size for monbodb node pool"
  type        = string
  default     = null
}
variable "mongodb_node_pool_node_count" {
  description = "VM count for monbodb node pool"
  type        = number
  default     = 1
}
variable "mongodb_node_pool_node_ephemeral_os_disk" {
  description = "Use of Ephemeral OS Disk for mongodb node pool"
  type        = bool
  default     = true
}
variable "userdb_node_pool_vm_size" {
  description = "VM size for monbodb node pool"
  type        = string
  default     = null
}
variable "userdb_node_pool_node_count" {
  description = "VM count for monbodb node pool"
  type        = number
  default     = 0
}
variable "userdb_node_pool_node_ephemeral_os_disk" {
  description = "Use of Ephemeral OS Disk for userdb node pool"
  type        = bool
  default     = true
}
variable "grafana_node_pool_vm_size" {
  description = "VM size for grafana node pool"
  type        = string
  default     = null
}
variable "grafana_node_pool_node_count" {
  description = "VM count for grafana node pool"
  type        = number
  default     = 1
}
variable "grafana_node_pool_node_ephemeral_os_disk" {
  description = "Use of Ephemeral OS Disk for grafana node pool"
  type        = bool
  default     = true
}
variable "keycloak_node_pool_vm_size" {
  description = "VM size for keycloak node pool"
  type        = string
  default     = null
}
variable "keycloak_node_pool_node_count" {
  description = "VM count for keycloak node pool"
  type        = number
  default     = 1
}
variable "keycloak_node_pool_node_ephemeral_os_disk" {
  description = "Use of Ephemeral OS Disk for keycloak node pool"
  type        = bool
  default     = true
}
variable "metrics_node_pool_vm_size" {
  description = "VM size for metrics node pool"
  type        = string
  default     = null
}
variable "metrics_node_pool_node_count" {
  description = "VM count for metrics node pool"
  type        = number
  default     = 1
}
variable "metrics_node_pool_node_ephemeral_os_disk" {
  description = "Use of Ephemeral OS Disk for metrics node pool"
  type        = bool
  default     = true
}
variable "ai_assistant_node_pool_vm_size" {
  description = "VM size for Vantiq ai assistant node pool"
  type        = string
  default     = null
}
variable "ai_assistant_node_pool_node_count" {
  description = "VM count for Vantiq ai assistant node pool"
  type        = number
  default     = 1
}
variable "ai_assistant_node_pool_node_ephemeral_os_disk" {
  description = "Use of Ephemeral OS Disk for Vantiq ai assistant node pool"
  type        = bool
  default     = true
}
variable "aks_node_subnet_id" {
  description = "subnet in which node group should be set up  "
  type        = string
  default     = null
}
variable "lb_subnet_id" {
  description = "subnet id to place the loadbalancer"
  type        = string
  default     = null
}

variable "log_analytics_workspace_sku" {
  description = "sku for log_analytics_workspace_sku"
  type        = string
  default     = "standard"
}

variable "loganalytics_enabled" {
  description = "whether log analytics should be enabled"
  type        = bool
  default     = false
}

variable "create_service_principal" {
  description = "subnet id to place the loadbalancer"
  type        = bool
  default     = false
}
