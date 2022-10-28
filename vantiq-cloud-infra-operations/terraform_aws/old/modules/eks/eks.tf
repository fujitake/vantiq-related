locals {
  node_labels = {
    "VANTIQ"   = "compute",
    "MongoDB"  = "database",
    "keycloak" = "shared",
    "grafana"  = "influxdb",
    "mertics"  = "compute"
  }
}

resource "aws_key_pair" "worker" {
  key_name_prefix = "${var.cluster_name}-eks-worker-"
  public_key      = file(var.worker_access_ssh_key_name)
  tags = {
    KubernetesCluster = var.cluster_name
    environment       = var.env_name
    instance          = "eks-worker"
  }
}

###
###  EKS Cluster
###
resource "aws_eks_cluster" "vantiq-eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks-cluster-role.arn
  version  = var.cluster_version
  tags = {
    KubernetesCluster = var.cluster_name
    environment       = var.env_name
  }

  vpc_config {
    subnet_ids = concat(var.public_subnet_ids, var.private_subnet_ids)
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-policy,
    aws_iam_role_policy_attachment.eks-service-policy,
  ]
}

###
### Maneged Node Group
###
resource "aws_eks_node_group" "vantiq-nodegroup" {
  for_each        = var.managed_node_group_config
  cluster_name    = aws_eks_cluster.vantiq-eks.name
  node_group_name = "${each.key}-nodegroup"
  node_role_arn   = aws_iam_role.eks-worker-node-role.arn

  ami_type       = each.value.ami_type
  instance_types = each.value.instance_types
  disk_size      = each.value.disk_size
  subnet_ids     = var.private_subnet_ids

  remote_access {
    ec2_ssh_key               = aws_key_pair.worker.key_name
    source_security_group_ids = var.basion_ec2_sg_ids
  }

  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    max_size     = each.value.scaling_config.max_size
    min_size     = each.value.scaling_config.min_size
  }

  labels = {
    "vantiq.com/workload-preference" = local.node_labels[each.key]
  }

  lifecycle {
    ignore_changes = [scaling_config]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-worker-node,
    aws_iam_role_policy_attachment.ecr-ro,
    aws_iam_role_policy_attachment.eks-cni
  ]

}

###
###  IAM Role( for Master(EKS) attach)
###
resource "aws_iam_role" "eks-cluster-role" {
  name = "${var.cluster_name}-vantiq-eks-cluster-role"
  path = "/"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-role.name
}

resource "aws_iam_role_policy_attachment" "eks-service-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks-cluster-role.name
}

###
### IAM Role(fot Worker Node)
###
resource "aws_iam_role" "eks-worker-node-role" {
  name = "${var.cluster_name}-vantiq-eks-worker-node-role"
  path = "/"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-worker-node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-worker-node-role.name
}

resource "aws_iam_role_policy_attachment" "ecr-ro" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-worker-node-role.name
}

resource "aws_iam_role_policy_attachment" "eks-cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-worker-node-role.name
}