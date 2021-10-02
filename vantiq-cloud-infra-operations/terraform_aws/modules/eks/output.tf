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
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.vantiq-eks.endpoint}
    certificate-authority-data: ${aws_eks_cluster.vantiq-eks.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.cluster_name}"
KUBECONFIG

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

output "kubectl-config" {
  value = local.kubeconfig
}

output "EKS-ConfigMap" {
  value = local.eks_configmap
}