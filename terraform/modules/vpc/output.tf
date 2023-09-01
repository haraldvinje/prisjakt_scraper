output "vpc_id" {
  value = aws_vpc.prisjakt_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.prisjakt_public_subnet.id
}

output "private_subnet_ids" {
  value = [aws_subnet.prisjakt_private_subnet_a.id, aws_subnet.prisjakt_private_subnet_b.id]
}

output "bastion_host_security_group_id" {
  value = module.bastion_host.bastion_host_security_group_id
}

output "bastion_host_id" {
  value = module.bastion_host.bastion_host_id
}
