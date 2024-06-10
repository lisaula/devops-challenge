locals {
  env                   = terraform.workspace
  account_id            = data.aws_caller_identity.current.account_id
  region_map            = lookup(var.aws_region_map, var.aws_region)
  execution_role_arn    = format("arn:aws:iam::%s:role/ecsTaskExecutionRole", local.account_id)
  ecs_service_role      = format("arn:aws:iam::%s:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS", local.account_id)
  aws_logs_region       = var.aws_region
  awslogs_stream_prefix = format("ecs")
}

# Get current user identity
data "aws_caller_identity" "current" {}

# Get VPC id
data "aws_vpc" "vpc" {
  state = "available"
  tags = {
    ASC_Environment  = local.env,
    Name = format("%s-%s-vpc001", local.env, local.region_map)
  }
}

# Cloudwatch Log Groups where the logs are sent by the containers
resource "aws_cloudwatch_log_group" "lg" {
  for_each = var.task_definitions
  
  name              = format("/%s/%s-%s-tdf", local.awslogs_stream_prefix, local.env, each.value.family_name)
  retention_in_days = 30
  lifecycle {
    ignore_changes = [ name, tags_all, skip_destroy]
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name               = format("%s-ecs001", local.env)

  lifecycle {
    ignore_changes = []
  }
}

# Capacity Provider
resource "aws_ecs_cluster_capacity_providers" "fargate" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
}

# ECS Task Definitions
resource "aws_ecs_task_definition" "td" {
  for_each = var.task_definitions

  family                   = format("%s-%s", local.env, each.value.family_name)
  execution_role_arn       = format("arn:aws:iam::%s:role/%s", local.account_id, each.value.task_role_arn)
  task_role_arn            = format("arn:aws:iam::%s:role/%s", local.account_id, each.value.task_role_arn)
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.cpu
  memory                   = (each.value.memory)


  container_definitions = templatefile(
    "${path.module}/tasks/${each.key}.json.tmpl",
    {
      name              = format("%s", each.value.family_name)
      cpu               = local.env == "prod"? 0 : each.value.cpu
      memory            = each.value.memory
      task_role_arn     = format("arn:aws:iam::%s:role/%s", local.account_id, each.value.task_role_arn)
      image             = format("%s.dkr.ecr.%s.amazonaws.com/%s", local.account_id, var.aws_region, each.value.image)
      environment       = jsonencode([for k, v in each.value.environment : { name = k, value = v }])
      container_port    = lookup(each.value.port_mappings, "ContainerPort")
      host_port         = lookup(each.value.port_mappings, "HostPort")
      aws_logs_group    = aws_cloudwatch_log_group.lg[each.key].name
      log_stream_prefix = local.awslogs_stream_prefix
      aws_region        = var.aws_region
    }
  )

  lifecycle {
    ignore_changes = [tags, tags_all, skip_destroy]
  }
}

# ECS Service
resource "aws_ecs_service" "svc" {
  for_each                          = var.service_definitions
  name                              = format("%s-%s", local.env, each.value.name)
  cluster                           = format("arn:aws:ecs:%s:%s:cluster/%s", var.aws_region, local.account_id, each.value.cluster_name)
  task_definition                   = aws_ecs_task_definition.td[each.key].arn
  desired_count                     = each.value.desired_count
  launch_type                       = "FARGATE"
  enable_ecs_managed_tags           = true
  health_check_grace_period_seconds = each.value.grace_period

  load_balancer {
    target_group_arn = lookup(var.lb_target_groups, each.value.target_group)
    container_name   = format("%s", each.key)
    container_port   = each.value.container_port
  }

  network_configuration {
    security_groups = [
      for sg in each.value.security_groups :
      lookup(var.aws_sg, sg)
    ]
    subnets = [
      for subnet in each.value.svc_subnets :
      lookup(var.aws_subnets, subnet)
    ]
    assign_public_ip = each.value.assign_public_ip
  }

  deployment_controller {
    type = "ECS"
  }

  lifecycle {
    ignore_changes = [tags, tags_all, load_balancer, network_configuration]
  }
}
