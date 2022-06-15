
resource "aws_key_pair" "worker" {
  key_name_prefix = "${var.cluster_name}-eks-worker-"
  public_key      = file(var.worker_access_ssh_key_name)
  tags = {
    KubernetesCluster = var.cluster_name
    environment       = var.env_name
    instance = "eks-worker"
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
    //security_group_ids =[aws_security_group_rule.vantiq-eks-master-eni-sg.id]
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

  lifecycle {
    ignore_changes = [scaling_config]
  }

  # scaling_config {
  #   desired_size = 5
  #   max_size     = 6
  #   min_size     = 1
  # }

  depends_on = [
    aws_iam_role_policy_attachment.eks-worker-node,
    aws_iam_role_policy_attachment.ecr-ro,
    aws_iam_role_policy_attachment.eks-cni
  ]

}

###
###  Master Security Group(created by EKS) edit rule
###  Setup this Security Group, if use Self Managed Node Group
###  (Mangeged Node Group unable to custom worker node security group)
###
# resource "aws_security_group_rule" "master-inbound-from-worker" {
#   description = "Allow pods to communicate with the cluster API Server"
#   type        = "ingress"
#   from_port   = 443
#   to_port     = 443
#   protocol    = "tcp"
#   source_security_group_id = aws_security_group.worker.id

#   security_group_id = aws_eks_cluster.vantiq-eks.vpc_config[0].cluster_security_group_id
# }

# resource "aws_security_group_rule" "master-outbound-to-pods" {
#   description = "Allow the cluster control plane to communicate with worker Kubelet and pods"
#   type        = "egress"
#   from_port   = 1025
#   to_port     = 65535
#   protocol    = "tcp"
#   source_security_group_id = aws_security_group.worker.id

#   security_group_id = aws_eks_cluster.vantiq-eks.vpc_config[0].cluster_security_group_id
# }

# resource "aws_security_group_rule" "master-outbound-to-worker-443" {
#   description = "Allow the cluster control plane to communicate with pods running extension API servers on port 443"
#   type        = "egress"
#   from_port   = 443
#   to_port     = 443
#   protocol    = "tcp"
#   source_security_group_id = aws_security_group.worker.id

#   security_group_id = aws_eks_cluster.vantiq-eks.vpc_config[0].cluster_security_group_id
# }

###
###  Security Group to attach worker node
###  Setup this Security Group, if use Self Managed Node Group
###  (Mangeged Node Group unable to custom security group) 
###
# resource "aws_security_group" "worker" {
#   name        = "${var.env_name}-worker-node-sg"
#   vpc_id      = var.vpc_id

#   tags = {
#     KubernetesCluster                          = var.cluster_name
#     "kubernetes.io/cluster/${var.cluster_name}" = "owned"
#   }
# }

# resource "aws_security_group_rule" "worker-inbound-self" {
#   description = "Allow node to communicate with each other"
#   type        = "ingress"
#   from_port   = 0
#   to_port     = 65535
#   protocol    = "-1"
#   self = true

#   security_group_id = aws_security_group.worker.id
# }

# resource "aws_security_group_rule" "worker-inbound-from-master" {
#   description = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
#   type        = "ingress"
#   from_port   = 1025
#   to_port     = 65535
#   protocol    = "tcp"
#   source_security_group_id = aws_eks_cluster.vantiq-eks.vpc_config[0].cluster_security_group_id

#   security_group_id = aws_security_group.worker.id
# }

# resource "aws_security_group_rule" "worker-outbound-to-keycloak-db" {
#   description = "Allow worker and pods to communicate with keycloak db instance"
#   type        = "egress"
#   from_port   = var.keycloak_db_expose_port
#   to_port     = var.keycloak_db_expose_port
#   protocol    = "tcp"
#   source_security_group_id = var.keycloak_db_sg_id

#   security_group_id = aws_security_group.worker.id
# }

###  maybe remove 
# resource "aws_security_group_rule" "worker-outbound" {
#   type        = "egress"
#   from_port   = 0
#   to_port     = 0
#   protocol    = "-1"
#   cidr_blocks = ["0.0.0.0/0"]

#   security_group_id = aws_security_group.worker.id
# }


###
###  IAM Role( for Master(EKS) attach)
###
resource "aws_iam_role" "eks-cluster-role" {
  name = "vantiq-eks-cluster-role"
  path = "/"
  # assume_role_policy = file("cluster-role-policy.json")
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
  name = "vantiq-eks-worker-node-role"
  path = "/"
  # assume_role_policy = file("worker-role-policy.json")
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