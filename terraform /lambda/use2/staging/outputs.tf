output "aws_subnets" {
  value = module.lambda_function.aws_subnets
}

output "aws_sgs" {
  value = module.lambda_function.aws_sgs
}