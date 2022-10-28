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

data "template_file" "basion" {
  template = file("${path.module}/basion-userdata.sh.tpl")
  vars = {
    basion_kubectl_version    = var.basion_kubectl_version
    worker_access_private_key = file(var.worker_access_private_key)
  }
}

resource "aws_key_pair" "basion" {
  key_name_prefix = "${var.cluster_name}-basion-"
  public_key      = file(var.basion_access_public_key_name)
  tags = {
    KubernetesCluster = var.cluster_name
    environment       = var.env_name
    instance          = "basion"
  }
}

###
###  Basion EC2 Instance
###
resource "aws_instance" "basion" {
  ami                    = data.aws_ami.ubuntu.image_id
  vpc_security_group_ids = [aws_security_group.basion-ssh-allow.id]
  subnet_id              = var.basion_subnet_id
  key_name               = aws_key_pair.basion.key_name
  instance_type = var.basion_instance_type
  user_data     = data.template_file.basion.rendered

  tags = {
    Name              = "${var.env_name}-basion-instance-for-${var.cluster_name}"
    KubernetesCluster = var.cluster_name
    environment       = var.env_name
  }
}

###
###  Elastic IP
###
resource "aws_eip" "basion-access-ip" {
  instance = aws_instance.basion.id
  vpc      = true
}

resource "aws_eip_association" "basion" {
  allocation_id = aws_eip.basion-access-ip.id
  instance_id   = aws_instance.basion.id
}

###
###  Security Group to attach basion instance
###
resource "aws_security_group" "basion-ssh-allow" {
  name   = "${var.env_name}-basion-ssh-allow-${var.cluster_name}"
  vpc_id = var.basion_vpc_id

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
