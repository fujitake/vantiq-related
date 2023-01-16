locals {
  name             = "aws-ebs-csi-driver"
  namespace        = "kube-system"
  service_account  = "ebs-csi-controller-sa"
  cluster_eks_name = var.cluster_eks_name
  addon_config     = var.addon_config
  irsa_config      = var.irsa_config
}

locals {
  irsa_iam_policies = concat([data.aws_iam_policy.ebs-csi-driver-policy.arn], lookup(local.addon_config, "additional_iam_policies", []))
}

data "aws_iam_policy" "ebs-csi-driver-policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

data "aws_eks_addon_version" "this" {
  addon_name         = local.name
  kubernetes_version = local.addon_config.kubernetes_version
  most_recent        = try(local.addon_config.most_recent, false)
}

resource "aws_eks_addon" "aws-ebs-csi-driver" {
  count = var.enabled ? 1 : 0

  cluster_name             = local.cluster_eks_name
  addon_name               = local.name
  addon_version            = try(local.addon_config.addon_version, data.aws_eks_addon_version.this.version)
  resolve_conflicts        = local.addon_config.resolve_conflicts
  service_account_role_arn = aws_iam_role.irsa[0].arn
  preserve                 = try(local.addon_config.preserve, true)

}

resource "aws_iam_role" "irsa" {
  count = (var.enabled && local.irsa_iam_policies != null) ? 1 : 0

  name        = format("%s-%s-%s", trim(local.service_account, "-*"), "irsa", local.cluster_eks_name)
  description = "AWS IAM Role for the Kubernetes service account ${local.service_account}."
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : local.irsa_config.eks_oidc_provider_arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringLike" : {
            "${local.irsa_config.eks_oidc_provider}:sub" : "system:serviceaccount:${local.namespace}:${local.service_account}",
            "${local.irsa_config.eks_oidc_provider}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "irsa" {
  count = (var.enabled && local.irsa_iam_policies != null) ? length(local.irsa_iam_policies) : 0

  policy_arn = local.irsa_iam_policies[count.index]
  role       = aws_iam_role.irsa[0].name
}

data "tls_certificate" "vantiq-eks" {
  count = var.enabled ? 1 : 0

  url = var.irsa_config.eks_oidc_issuer
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  count = var.enabled ? 1 : 0

  client_id_list = [
    "sts.amazonaws.com"
  ]
  thumbprint_list = data.tls_certificate.vantiq-eks[0].certificates[*].sha1_fingerprint
  url             = var.irsa_config.eks_oidc_issuer
}