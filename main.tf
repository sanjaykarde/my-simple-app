provider "aws" {
  region = "ap-south-1"
}

# Create ECS Cluster
resource "aws_ecs_cluster" "my_cluster" {
  name = "my-simple-app-cluster"
}

# Create ECS Task Definition
resource "aws_ecs_task_definition" "my_task" {
  family                   = "my-simple-app-task"
  network_mode             = "awsvpc"
  container_definitions    = jsonencode([{
    name  = "my-app"
    image = "${var.ecr_repo_uri}:${var.build_number}"
    memory = 512
    cpu    = 256
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }]
  }])

  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  memory                   = "1024"
  cpu                      = "512"
}

# Create ECS Service
resource "aws_ecs_service" "my_service" {
  name            = "my-simple-app-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 1

  launch_type = "FARGATE"
  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.my_target_group.arn
    container_name   = "my-app"
    container_port   = 80
  }
}

# Create Load Balancer (optional)
resource "aws_lb" "my_load_balancer" {
  name               = "my-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "my_target_group" {
  name     = "my-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.my_cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.my_service.name
}

resource "aws_ecr_repository" "my_simple_app" {
  name                 = "my-simple-app"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

