# Global variables
variable "aws_region" {
  description = "Region used in project."
  type        = string
  default     = "us-east-1"
}

variable "lambda" {
  description = "ECS Task Definition"
  type        = map(any)
}

variable "vpc_configs" {
  default     = null
  description = "Provide this to allow your function to access your VPC. Fields documented below. See Lambda in VPC."
  type = map(
    object({
      security_group_ids = list(string)
      subnet_ids         = list(string)
    })
  )
}