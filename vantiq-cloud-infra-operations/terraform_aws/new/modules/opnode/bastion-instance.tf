data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "bastion" {
  template = file("${path.module}/bastion-userdata.sh.tpl")
  vars = {
    jdk_version               = var.bastion_jdk_version
    bastion_kubectl_version   = var.bastion_kubectl_version
    worker_access_private_key = file(var.worker_access_private_key)
  }
}

resource "aws_key_pair" "bastion" {
  count           = var.enabled ? 1 : 0
  key_name_prefix = "${var.cluster_name}-bastion-"
  public_key      = file(var.bastion_access_public_key_name)
  tags = {
    KubernetesCluster = var.cluster_name
    environment       = var.env_name
    instance          = "bastion"
  }
}

###
###  bastion EC2 Instance
###
resource "aws_instance" "bastion" {
  count                  = var.enabled ? 1 : 0
  ami                    = data.aws_ami.ubuntu.image_id
  vpc_security_group_ids = [aws_security_group.bastion-ssh-allow[0].id]
  subnet_id              = var.bastion_subnet_id
  key_name               = aws_key_pair.bastion[0].key_name
  instance_type          = var.bastion_instance_type
  user_data              = data.template_file.bastion.rendered

  tags = {
    Name              = "${var.env_name}-bastion-instance-for-${var.cluster_name}"
    KubernetesCluster = var.cluster_name
    environment       = var.env_name
  }
}

###
###  Elastic IP
###
resource "aws_eip" "bastion-access-ip" {
  count    = var.enabled ? 1 : 0
  instance = aws_instance.bastion[0].id
  vpc      = true
}

resource "aws_eip_association" "bastion" {
  count         = var.enabled ? 1 : 0
  allocation_id = aws_eip.bastion-access-ip[0].id
  instance_id   = aws_instance.bastion[0].id
}

###
###  Security Group to attach bastion instance
###
resource "aws_security_group" "bastion-ssh-allow" {
  count  = var.enabled ? 1 : 0
  name   = "${var.env_name}-bastion-ssh-allow-${var.cluster_name}"
  vpc_id = var.bastion_vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
