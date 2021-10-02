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

###
###  Basion EC2 Instance
###
resource "aws_instance" "basion" {
  ami                    = data.aws_ami.ubuntu.image_id
  vpc_security_group_ids = [aws_security_group.basion-ssh-allow.id]
  subnet_id              = module.vpc.public_subnet_ids[0]
  key_name               = local.worker_access_ssh_key_name
  instance_type          = "t2.micro"

  tags = {
    Name              = "${local.env_name}-basion-instance-for-${local.cluster_name}"
    KubernetesCluster = local.cluster_name
    environment       = local.env_name
  }
}

###
###  Elastic IP
###
resource "aws_eip" "basion-access-ip" {
  instance = aws_instance.basion.id
  vpc      = true
}

###
###  Security Group to attach basion instance
###
resource "aws_security_group" "basion-ssh-allow" {
  name   = "${local.env_name}-basion-ssh-allow-${local.cluster_name}"
  vpc_id = module.vpc.vpc_id

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
