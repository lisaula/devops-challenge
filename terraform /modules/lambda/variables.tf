# Remote state data refrences (source: network)
variable "aws_region" {
  description = "Region used in project."
  type        = string
  default     = "us-east-1"
}

variable "aws_subnets" {
  description = "Reference to all Subnet ID(s) (module: subnet)."
  type        = map(string)
}

# Remote state data refrences (source: compute)
variable "aws_sg" {
  description = "Reference to all Security Groups ID(s) (module: sg)."
  type        = map(string)
}

variable "lambda" {
  description = "ECS Task Definition"
  type        = map(
    object({
      function_name = string
      description        = string
      role               = string 
      create_role = optional(bool)
      handler            = optional(string)
      runtime            = optional(string)
      package_type = string
      memory_size        = number 
      timeout = number
      image_uri = optional(string)
      environment        = optional(map(any))
      vpc_config = bool//optional(map(any))
      tags = map(any)
    })
  )
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

variable "aws_region_map" {
  description = "AWS Region Mapping to abbrevated names."
  type        = map(string)
  default = {
    ap-south-1     = "aps1"
    eu-west-2      = "euw2"
    eu-west-1      = "euw1"
    ap-northeast-2 = "apne2"
    ap-northeast-1 = "apne1"
    sa-east-1      = "sae1"
    ca-central-1   = "cac1"
    ap-southeast-1 = "apse1"
    ap-southeast-2 = "apse2"
    eu-central-1   = "euc1"
    us-east-1      = "use1"
    us-east-2      = "use2"
    us-west-1      = "usw1"
    us-west-2      = "usw2"
  }
}
