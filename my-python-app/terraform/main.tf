provider "aws" {
  region = "us-east-1"
}

resource "aws_sns_topic" "notification" {
  name = "ci-cd-sns-topic"
}

resource "aws_ecs_cluster" "fargate_cluster" {
  name = "ci-cd-cluster"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "python-app"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role
  container_definitions    = jsonencode([
    {
      name      = "python-app"
      image     = var.docker_image
      portMappings = [{
        containerPort = 5000
        protocol      = "tcp"
      }]
    }
  ])
}

resource "aws_ecs_service" "app_service" {
  name            = "python-app-service"
  cluster         = aws_ecs_cluster.fargate_cluster.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnets
    security_groups = [var.security_group]
    assign_public_ip = true
  }
}

