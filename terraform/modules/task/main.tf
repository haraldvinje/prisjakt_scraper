resource "aws_security_group" "container_security_group" {
  name   = "${var.task_name}-security-group"
  vpc_id = var.vpc_id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_ecr_repository" "prisjakt_repo" {
  name                 = var.task_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_cluster" "prisjakt_cluster" {
  name = "${var.task_name}-cluster"
}

resource "aws_iam_policy" "rds_access_policy" {
  name = "${var.task_name}-rds-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-db:connect"
        ]
        Resource = var.database_arn
      }
    ]
  })
}

resource "aws_iam_policy" "secrets_manager_access" {
  name = "${var.task_name}-secrets-manager-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.database_credentials_secret_arn
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.task_name}_TaskRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_rds_policy_attachment" {
  policy_arn = aws_iam_policy.rds_access_policy.arn
  role       = aws_iam_role.ecs_task_role.name
}

resource "aws_iam_role_policy_attachment" "ecs_task_secrets_manager_policy_attachment" {
  policy_arn = aws_iam_policy.secrets_manager_access.arn
  role       = aws_iam_role.ecs_task_role.name
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.task_name}_TaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ecr_access_policy" {
  name = "${var.task_name}_EcrAndLogsAccessPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetAuthorizationToken",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}

resource "aws_ecs_task_definition" "prisjakt_task_definition" {
  family                   = "${var.task_name}-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  container_definitions = jsonencode([{
    name  = "${var.task_name}-container"
    image = "${aws_ecr_repository.prisjakt_repo.repository_url}:latest"
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-create-group  = "true"
        awslogs-group         = "prisjakt-scraping-logger",
        awslogs-region        = "eu-west-1",
        awslogs-stream-prefix = "scraper"
      }
    }
  }])
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_iam_role" "prisjakt_scheduler_role" {
  name = "${var.task_name}_SchedulerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_policy" "scheduler_task_execution_policy" {
  name = "${var.task_name}_ExecutionPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:RunTask"
        ]
        Resource = [
          aws_ecs_task_definition.prisjakt_task_definition.arn
        ]
        Condition = {
          ArnEquals = {
            "ecs:cluster" = aws_ecs_cluster.prisjakt_cluster.arn
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          "*"
        ]
        Condition = {
          StringLike = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      },

    ]
  })
}

resource "aws_iam_role_policy_attachment" "prisjakt_scheduler_policy_attachment" {
  role       = aws_iam_role.prisjakt_scheduler_role.name
  policy_arn = aws_iam_policy.scheduler_task_execution_policy.arn
}

resource "aws_scheduler_schedule" "prisjakt_task_schedule" {
  name       = "${var.task_name}-schedule"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = var.schedule_expression

  target {
    arn      = aws_ecs_cluster.prisjakt_cluster.arn
    role_arn = aws_iam_role.prisjakt_scheduler_role.arn
    ecs_parameters {
      task_definition_arn = aws_ecs_task_definition.prisjakt_task_definition.arn
      launch_type         = "FARGATE"
      network_configuration {
        security_groups  = [aws_security_group.container_security_group.id]
        subnets          = [var.subnet_id]
        assign_public_ip = true
      }
    }
  }
}
