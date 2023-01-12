output "vpc_id" {
  value = aws_vpc.vantiq-vpc.id
}
output "public_subnet_ids" {
  value = values(aws_subnet.public)[*].id
}
output "private_subnet_ids" {
  value = values(aws_subnet.private)[*].id
}
