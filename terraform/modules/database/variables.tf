variable "database_name" {
  type        = string
  description = "Name of database"
}

variable "vpc_id" {
  type        = string
  description = "Id of the VPC for the database to reside in"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Ids of the subnet for the database to reside in"
}

variable "container_security_group_id" {
  type        = string
  description = "Id of security group of the ECS container running the task"
}

variable "bastion_host_security_group_id" {
  type        = string
  description = "Id of the bastion host's security group"
}
