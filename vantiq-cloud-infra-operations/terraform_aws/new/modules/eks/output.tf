output "cluster_security_group_id" {
  value = aws_eks_cluster.vantiq-eks.vpc_config[0].cluster_security_group_id
}

output "cluster_eks_name" {
  value = aws_eks_cluster.vantiq-eks.name
}

# output "worker_security_group_id" {
#   value = aws_security_group.worker.id
# }

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