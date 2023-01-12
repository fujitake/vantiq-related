output "cluster_security_group_id" {
  value = aws_eks_cluster.vantiq-eks.vpc_config[0].cluster_security_group_id
}

output "cluster_eks_name" {
  value = aws_eks_cluster.vantiq-eks.name
}

output "oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  value       = replace(aws_eks_cluster.vantiq-eks.identity[0].oidc[0].issuer, "https://", "")
}

output "oidc_issuer" {
  description = "The OpenID Connect issuer"
  value       = aws_eks_cluster.vantiq-eks.identity[0].oidc[0].issuer
}

output "cluster_id" {
  description = "The ID of the EKS cluster. Note: currently a value is returned only for local EKS clusters created on Outposts"
  value       = aws_eks_cluster.vantiq-eks.cluster_id
}

###
###  kubeconfig Output
###
locals {
  eks_configmap = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.eks-worker-node-role.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}

output "EKS-ConfigMap" {
  value = local.eks_configmap
}