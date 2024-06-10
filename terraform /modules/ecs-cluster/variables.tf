variable "aws_region" {
  description = "Region used in project."
  type        = string
}

variable "aws_region_map" {
  description = "AWS Region Mapping to abbrevated names."
  type        = map(string)
  default = {
    eu-central-1   = "euc1"
    us-east-2 = "use2"
  }
}

variable "aws_dns" {
  description = "AWS Route53 internal zone ID."
  type        = map(string)
  default = {
    name = "devops-challenge.com"
    id   = "xxxxxxx"
    ttl  = 300
  }
}

variable "task_definitions" {
  description = "ECS Task Definition"
  type        = map(any)
}

variable "service_definitions" {
  description = "ECS Service Definition"
  type        = map(any)
}

# Remote state data refrences (source: network)
variable "aws_subnets" {
  description = "Reference to all Subnet ID(s) (module: subnet)."
  type        = map(string)
}

# Remote state data refrences (source: compute)
variable "aws_sg" {
  description = "Reference to all Security Groups ID(s) (module: sg)."
  type        = map(string)
}

# Remote state data refrences (source: compute)
variable "lb_target_groups" {
  description = "Reference to all LB Target groups ARN(s) (module: alb)."
  type        = map(string)
}