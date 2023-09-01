output "bastion_host_id" {
  value = aws_instance.bastion_host.id
}

output "bastion_host_security_group_id" {
  value = aws_security_group.bastion_host_security_group.id
}
