# Global variables

/*terraform {
  experiments = [module_variable_optional_attrs]
}*/
variable "aws_region" {
  description = "Region used in project."
  type        = string
}

variable "aws_region_map" {
  description = "AWS Region Mapping to abbrevated names."
  type        = map(string)
  default = {
    eu-central-1   = "euc1"
  }
}

variable "aws_dns" {
  description = "AWS Route53 internal zone ID."
  type        = map(string)
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
      enable_waf_fail_open = optional(bool)
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
  description = "Load Balancers target groups."
  type = map(
    object({
      target_type          = string
      protocol_port        = string
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
# Remote state references
# Remote state data refrences (source: sg)
variable "aws_sg" {
  description = "Reference to ALB instance Security Groups' ID (module: sg)."
  type        = map(string)
}
variable "aws_subnets" {
  description = "Reference to all Subnet ID(s) (module: subnet)."
  type        = map(string)
}
