variable "enabled" {
  description = "ebs-csi-driver addon create flag"
  type        = bool
  default     = true
}

variable "cluster_eks_name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "addon_config" {
  description = "Amazon EKS Managed Add-on config for EBS CSI Driver"
  type        = any
  default     = {}
}

variable "irsa_config" {
  description = "IRSA config for EBS CSI Driver"
  type        = any
  default     = {}
}
