
# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
locals {
  account_id            = data.aws_caller_identity.current.account_id
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

# Get current user identity
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "lambda_logging" {
  for_each = var.lambda
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:${var.aws_region}:${local.account_id}:log-group:/aws/lambda/${each.value.function_name}*"]
  }
}

data "aws_iam_policy" "AWSLambdaVPCAccessExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}


resource "aws_iam_policy" "lambda_logging" {
  for_each = var.lambda
  name        = "lambda_logging_${var.aws_region_map[var.aws_region]}_${each.value.function_name}"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging[each.key].json
}

data "aws_iam_role" "role" {
    for_each = {for role in local.rolesData: role.name => role}     
    name = each.value.role_name
}


resource "aws_iam_role" "lambda_role" {
  for_each = {for role in local.rolesconfig: role.name =>  role}
  name = each.value.role_name

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
  tags = {
    "Name" = each.value.role_name
    "Region" = "global"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_logs_role" {
  for_each = {for role in local.rolesconfig: role.name =>  role}
  role       = aws_iam_role.lambda_role[each.key].name
  policy_arn = aws_iam_policy.lambda_logging[each.key].arn
  depends_on = [ aws_iam_role.lambda_role ]
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_role" {
  for_each = {for key, lambda in var.lambda: key => lambda if lambda.vpc_config}
  role       = each.value.role
  policy_arn = data.aws_iam_policy.AWSLambdaVPCAccessExecutionRole.arn

  depends_on = [ aws_iam_role.lambda_role ]
}