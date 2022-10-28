###
### DB Password
###
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

locals {
  db_password = var.db_password != null ? var.db_password : random_password.db_password.result
}

###
###  keycloak RDS subnet group
###
resource "aws_db_subnet_group" "keycloak" {
  name       = "${var.env_name}-keycloak-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    KubernetesCluster = var.cluster_name
    environment       = var.env_name
    Name              = "${var.env_name}-keycloak-db-subnet-group"
  }
}


###
###  keycloak RDS instance(internal vpc)
###
resource "aws_db_instance" "keycloak-postgres" {
  identifier             = "${var.cluster_name}-keycloak-postgresql"
  allocated_storage      = var.db_storage_size
  storage_type           = var.db_storage_type
  engine                 = "postgres"
  engine_version         = var.postgres_engine_version
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = local.db_password
  port                   = var.db_expose_port
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.keycloak.id
  vpc_security_group_ids = [aws_security_group.keycloak.id]
  skip_final_snapshot    = true
  # final_snapshot_identifier = "keycloak-postgresql-final"
  auto_minor_version_upgrade = false

  lifecycle {
    ignore_changes = [password]
  }
}


###
###  Security Group to attach keycloak db instance
###
resource "aws_security_group" "keycloak" {
  name   = "${var.env_name}-keycloak-db-sg"
  vpc_id = var.db_vpc_id

  ingress {
    from_port = var.db_expose_port
    to_port   = var.db_expose_port
    protocol  = "tcp"
    # cidr_blocks = ["0.0.0.0/0"]

    #  Change this Security Group, if use Self Managed Node Group
    #  This value is managed node group
    security_groups = [var.worker_node_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}