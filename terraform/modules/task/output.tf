output "container_security_group_id" {
  value = aws_security_group.container_security_group.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.prisjakt_cluster.name
}

output "ecs_task_definition_arn" {
  value = aws_ecs_task_definition.prisjakt_task_definition.arn_without_revision
}
output "scheduler_network_configuration" {
  value = aws_scheduler_schedule.prisjakt_task_schedule.target[0].ecs_parameters[0].network_configuration
}
