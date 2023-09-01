output "database_address" {
  value = module.database.database_address
}

output "database_port" {
  value = module.database.database_port
}

output "bastion_host_id" {
  value = module.vpc.bastion_host_id
}

output "database_credentials_secret_arn" {
  value = module.database.database_credentials_secret_arn
}

output "ecs_cluster_name" {
  value = module.task.ecs_cluster_name
}

output "ecs_task_definition_arn" {
  value = module.task.ecs_task_definition_arn
}

output "scheduler_network_configuration" {
  value = module.task.scheduler_network_configuration
}
