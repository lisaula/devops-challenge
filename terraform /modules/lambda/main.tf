locals {
  env = terraform.workspace
}

resource "aws_cloudwatch_log_group" "lambda" {
  for_each = var.lambda
  name              = format("/aws/lambda/%s",each.value.function_name)
  retention_in_days = 14
}

data "archive_file" "lambda_function_zip" {
  type        = "zip"
  output_path = "${path.module}/.terraform/archive_files/example.zip"
  source {
    content = "Hello"
    filename = "file.txt"
  }
}


resource "aws_lambda_function" "this" {
  for_each = var.lambda
  filename = each.value.package_type == "Zip" ? data.archive_file.lambda_function_zip.output_path : null
  image_uri = each.value.image_uri
  description = each.value.description
  function_name = each.value.function_name
  role          = try(data.aws_iam_role.role[each.key].arn, aws_iam_role.lambda_role[each.key].arn)
  handler       = each.value.handler
  package_type = each.value.package_type
  runtime = each.value.runtime
  memory_size = each.value.memory_size
  publish = false
  timeout = each.value.timeout
  environment {
    variables = each.value.environment
  }

  dynamic "vpc_config" {
    for_each = each.value.vpc_config == true ? [true] : []
    content {
      security_group_ids = var.vpc_configs[each.key].security_group_ids
      subnet_ids         =  var.vpc_configs[each.key].subnet_ids
    }
  }
    tags = merge(
    { "Name" = each.value.function_name },
    each.value.tags
    )
  lifecycle {
    ignore_changes = [filename]
  }
  depends_on = [ aws_iam_role.lambda_role, aws_iam_role_policy_attachment.lambda_vpc_role ]
}