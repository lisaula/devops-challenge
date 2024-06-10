# Global variables
variable "aws_region" {
  description = "Region used in project."
  type        = string
  default     = "eu-central-1"
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

variable "aws_dns" {
  description = "AWS Route53 internal zone ID."
  type        = map(string)
  default = {
    name = "coloroin.com"
    id   = "Z0754125BEJU9TGTLOIR"
    ttl  = 300
  }
}

variable "lb" {
  description = "AWS Load Balance instances."
  type = map(
    object({
      type                = string
      internal            = bool
      deletion_protection = bool
      preserve_host_header = bool
      idle_timeout        = optional(number)
      lb_sg               = optional(string)
      lb_subnets          = list(string)
      ssl_certificate     = optional(list(string))
      access_logs = optional(
        object({
          enabled = bool
          bucket  = optional(string)
          prefix  = optional(string)
        })
      )
      listeners = list(
        object({
          protocol       = string
          default_action = optional(string)
          port           = optional(number)
          tg_name        = optional(string)
        })
      )
      listener_rules = optional(
        map(
          list(
            object({
              priority     = string
              action       = optional(string)
              path_pattern = optional(list(string))
              host_header  = optional(list(string))
              source_ip    = optional(list(string))
              tg_name      = optional(string)
            })
          )
        )
      )
      tags = map(any)
    })
  )
}

variable "lb_tg" {
  description = "Application LB target groups."
  type = map(
    object({
      target_type          = string
      protocol_port        = string
      lb_name              = string
      deregistration_delay = number
      stickiness = optional(map(
        object({
          enabled         = bool
          type            = string
          cookie_duration = number
        })
      ))
      health_check = map(any)
      tags         = map(string)
    })
  )
}

variable "lb_dns" {
  description = "Route53 Alias record for ALB instances."
  type        = map(any)
  default     = {}
}

variable "lb_dns_pub" {
  description = "Route53 Alias record for ALB instances."
  type        = map(any)
  default     = {}
}