##### for debug outputs ##### 

# output "vpc_id" {
#   value = module.vpc.vpc_id
# }  
# output "public_subnet_ids" {
#   value = module.vpc.public_subnet_ids
# }  
# output "private_subnet_ids" {
#   value = module.vpc.private_subnet_ids
# }  


##### for debug outputs #####

###
#  basion server info
###
output "basion-server-public-ip" {
  value = aws_instance.basion.public_ip
}

###
#  keycloak RDS info
###
output "keycloak-db-endpoint" {
  value = module.keycloak-db.postgres_endpoint
}
output "keycloak-db-admin-user" {
  value = module.keycloak-db.postgres_admin_user
}
output "keycloak-db-admin-password" {
  value = module.keycloak-db.postgres_admin_password
  sensitive = true
}
output "keycloak-db_name" {
  value = module.keycloak-db.postgres_db_name
}

###
#  EKS
###
output "cluster_eks_name" {
  value = module.eks.cluster_eks_name
}

output "kubectl-config" {
  value = module.eks.kubectl-config
}

output "EKS-ConfigMap" {
  value = module.eks.EKS-ConfigMap
}

output "kube_config_update_command" {
  value = format("aws eks update-kubeconfig --region %s --name %s", local.region, module.eks.cluster_eks_name)
}