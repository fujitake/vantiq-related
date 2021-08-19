output "postgres_endpoint" {
  value = aws_db_instance.keycloak-postgres.endpoint
}

output "postgres_admin_user" {
  value = aws_db_instance.keycloak-postgres.username
}

output "postgres_admin_password" {
  value = aws_db_instance.keycloak-postgres.password
}

output "postgres_db_name" {
  value = aws_db_instance.keycloak-postgres.name
}

output "keycloak_db_sg_id" {
  value = aws_security_group.keycloak.id
}

# output "postgres_admin_db_name" {
#   value = aws_db_instance.keycloak-postgres.
# }
