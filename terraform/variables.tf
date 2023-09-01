variable "app_name" {
  type        = string
  description = "App name to be used for naming resources"
}

variable "database_name" {
  type        = string
  description = "Name of database"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "vpc_name" {
  type        = string
  description = "AWS region"
}

variable "task_name" {
  type        = string
  description = "Name of scraping task"
}

variable "schedule_expression" {
  type        = string
  description = "When the task should be scheduled to run"
}

variable "repo_ref" {
  type        = string
  description = "Reference of GitHub organization, repository and branch"
}
