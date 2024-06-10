# 'ecs-cluster' module
module "ecs-cluster" {
  source              = "../../modules/ecs-cluster"
  aws_region          = var.aws_region
  aws_region_map      = var.aws_region_map
  task_definitions    = var.task_definitions
  service_definitions = var.service_definitions
  aws_subnets         = data.terraform_remote_state.network.outputs.aws_subnets
  aws_sg              = data.terraform_remote_state.sg.outputs.aws_sg
  lb_target_groups    = data.terraform_remote_state.lb_tg.outputs.target_groups
}