terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.21.0"
    }
  }

  required_version = ">= 1.2.0"
  backend "s3" {
    bucket = "prisjakt-scraper-terraform-remote-state"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source   = "./modules/vpc"
  vpc_name = var.vpc_name
}

module "task" {
  source = "./modules/task"

  task_name                       = var.task_name
  schedule_expression             = var.schedule_expression
  vpc_id                          = module.vpc.vpc_id
  subnet_id                       = module.vpc.public_subnet_id
  database_arn                    = module.database.database_arn
  database_credentials_secret_arn = module.database.database_credentials_secret_arn
}

module "database" {
  source = "./modules/database"

  database_name                  = var.database_name
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnet_ids
  container_security_group_id    = module.task.container_security_group_id
  bastion_host_security_group_id = module.vpc.bastion_host_security_group_id
}

module "github_actions_iam" {
  source = "./modules/github_actions_iam"

  app_name = var.app_name
  repo_ref = var.repo_ref
}
