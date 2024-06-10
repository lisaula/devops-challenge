# Global variables
variable "aws_region" {
  description = "Region used in project."
  type        = string
  default     = "us-east-2"
}

variable "aws_region_map" {
  description = "AWS Region Mapping to abbrevated names."
  type        = map(string)
  default = {
    eu-central-1   = "euc1"
    us-east-2 = "use2"
  }
}

variable "aws_tags" {
  description = "Standard tags used for labeling resources."
  type        = map(string)
  default = {
    "IaaC"           = "terraform"
  }
}

variable "aws_dns" {
  description = "AWS Route53 internal zone ID."
  type        = map(string)
  default = {
    name = "devops-challenge.com"
    id   = "xxxxxx"
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