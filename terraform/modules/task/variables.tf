variable "task_name" {
  type        = string
  description = "Name of task. This will be used across resources related to creating the ECS task"
}

variable "schedule_expression" {
  type        = string
  description = "When the task should be scheduled to run"
}

variable "vpc_id" {
  type        = string
  description = "Id of the VPC to use for ECS task"
}

variable "subnet_id" {
  type        = string
  description = "Id of the subnet to use for ECS task"
}

variable "database_arn" {
  type        = string
  description = "ARN of the database to connect to from ECS"
}

variable "database_credentials_secret_arn" {
  type        = string
  description = "ARN of the SecretsManager secret to connect to the database"
}
