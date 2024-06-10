module "lambda_function" {
  source      = "../../modules/lambda"
  aws_sg      = data.terraform_remote_state.sg.outputs.aws_sg
  aws_subnets = data.terraform_remote_state.network.outputs.aws_subnets
  lambda      = var.lambda
  vpc_configs = var.vpc_configs
}

locals {
    rolesconfig = [
    for key, srv in var.lambda : {
      name = key
      role_name: srv.role
    } if srv.create_role
  ]
  rolesData = [
    for key, srv in var.lambda : {
      name = key
      role_name: srv.role
    } if !srv.create_role
  ]
}