###
#  basion server info
###
output "basion_ssh_allow_sg_id" {
  value       = module.opnode.basion_ssh_allow_sg_id
  description = "basion instance public ip"
}

output "basion_public_ip" {
  value       = module.opnode.basion_public_ip
  description = "basion instance public ip"
}
