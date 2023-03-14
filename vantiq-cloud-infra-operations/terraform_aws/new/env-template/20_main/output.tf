###
#  EKS
###
output "cluster_eks_name" {
  value = module.eks.cluster_eks_name
}
output "kube_config_update_command" {
  value = format("aws eks update-kubeconfig --region %s --name %s", module.constants.common_config.region, module.eks.cluster_eks_name)
}


###
#  RDS
###
output "postgres_db_name" {
  value       = module.keycloak-db.postgres_db_name
  description = "keycloak db name"
}
output "postgres_admin_user" {
  value       = module.keycloak-db.postgres_admin_user
  description = "keycloak db admin user name"
}
output "postgres_endpoint" {
  value       = module.keycloak-db.postgres_endpoint
  description = "keycloak db endpoint"
}
output "postgres_admin_password" {
  value       = module.keycloak-db.postgres_admin_password
  description = "keycloak db admin user password"
  sensitive   = true
}

###
#  Bastion instance
###
output "bastion_public_ip" {
  value       = module.constants.common_config.bastion_enabled ? module.opnode.bastion_public_ip : null
  description = "bastion instance public ip"
}