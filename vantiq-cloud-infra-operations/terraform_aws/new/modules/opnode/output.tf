output "bastion_public_ip" {
  # value = aws_instance.bastion.public_ip
  value       = one(aws_eip.bastion-access-ip[*].public_ip)
  description = "bastion instance public ip"
}

output "bastion_ssh_allow_sg_id" {
  value       = one(aws_security_group.bastion-ssh-allow[*].id)
  description = "Security Group ID attached bastion instance"
}

output "bastion_userdata" {
  value       = data.template_file.bastion.rendered
  description = "bastion instance user data"
}