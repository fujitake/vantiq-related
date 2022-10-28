output "basion_public_ip" {
  # value = aws_instance.basion.public_ip
  value       = aws_eip.basion-access-ip.public_ip
  description = "basion instance public ip"
}

output "basion_ssh_allow_sg_id" {
  value       = aws_security_group.basion-ssh-allow.id
  description = "Security Group ID attached basion instance"
}

output "basion_userdata" {
  value       = data.template_file.basion.rendered
  description = "basion instance user data"
}