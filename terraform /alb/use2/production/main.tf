module "alb" {
  source         = "../../modules/alb-v2"
  aws_region     = var.aws_region
  aws_region_map = var.aws_region_map
  aws_dns        = var.aws_dns
  lb             = var.lb
  lb_tg          = var.lb_tg
  lb_dns         = var.lb_dns
  lb_dns_pub     = var.lb_dns_pub
  aws_sg         = data.terraform_remote_state.sg.outputs.aws_sg
  aws_subnets    = data.terraform_remote_state.network.outputs.aws_subnets
}

