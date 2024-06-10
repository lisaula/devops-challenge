locals {
  env        = terraform.workspace
  region_map = lookup(var.aws_region_map, var.aws_region)
  dns_name   = lookup(var.aws_dns, "name")
  vpc_filter = "prod"
  protocol_ports = {
    HTTP  = 80,
    HTTPS = 443,
    TLS   = 443
  }
  listener_ssl_policy = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  alpn_policy         = "HTTP2Optional"
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [format("%s-%s-vpc001", local.vpc_filter, local.region_map)]
  }
}

# Default SSL certificate data gathering
data "aws_acm_certificate" "lb_ssl" {
  for_each = toset([for lb in var.lb : lb.ssl_certificate[0] if length(lb.ssl_certificate) > 0])

  domain      = each.value
  statuses    = ["ISSUED"]
  most_recent = true
}

resource "aws_lb" "lb" {
  for_each = var.lb

  name                       = format("%s-%s", local.env, each.key)
  load_balancer_type         = each.value.type
  internal                   = each.value.internal
  enable_deletion_protection = each.value.deletion_protection
  preserve_host_header = each.value.preserve_host_header
  idle_timeout               = each.value.idle_timeout
  security_groups = (each.value.lb_sg == null) ? null : [lookup(var.aws_sg, each.value.lb_sg)]
  subnets = [
    for lb_subnet in each.value.lb_subnets :
    lookup(var.aws_subnets, lb_subnet)
  ]

  timeouts {}

  access_logs {
    enabled = each.value.access_logs.enabled
    bucket  = each.value.access_logs.enabled == true ? each.value.access_logs.bucket : ""
    prefix  = each.value.access_logs.enabled == true ? each.value.access_logs.prefix : ""
  }

  tags = merge(
    { "Name" = format("%s-%s", local.env, each.key) },
    { "Info" = format("%s LB for %s %s", each.value.type, each.value.tags["Platform"], each.value.tags["Function"]) },
    { "Role" = each.value.internal == true ? "internal" : "internet-facing" },
    { "Tier" = each.value.type },
    each.value.tags
  )

  lifecycle {
    ignore_changes = [name, access_logs]
  }
}

resource "aws_lb_target_group" "tg" {
  for_each = var.lb_tg

  name = format("%s-%s-%s", local.env, each.value.tags["Platform"], each.key)

  vpc_id               = data.aws_vpc.vpc.id
  port                 = element(split(":", each.value.protocol_port), 1)
  protocol             = element(split(":", each.value.protocol_port), 0)
  target_type          = each.value.target_type
  deregistration_delay = each.value.deregistration_delay

  lifecycle {
    ignore_changes = [name, tags, tags_all]
  }

  dynamic "health_check" {
    for_each = [each.value.health_check]
    content {
      port                = lookup(health_check.value, "port", null)
      protocol            = lookup(health_check.value, "protocol", null)
      path                = lookup(health_check.value, "path", null)
      interval            = lookup(health_check.value, "interval", null)
      timeout             = lookup(health_check.value, "timeout", null)
      matcher             = lookup(health_check.value, "matcher", null)
      healthy_threshold   = lookup(health_check.value, "healthy_threshold", null)
      unhealthy_threshold = lookup(health_check.value, "unhealthy_threshold", null)
    }
  }

  dynamic "stickiness" {
    for_each = (each.value.stickiness == null) ? {} : each.value.stickiness
    content {
      enabled         = lookup(stickiness.value, "enabled", null)
      cookie_duration = lookup(stickiness.value, "cookie_duration", null)
      type            = lookup(stickiness.value, "type", null)
    }
  }

  tags = merge(
    { "Name" = format("%s-%s-%s", local.env, each.value.tags["Platform"], each.key) },
    { "Role" = "web" },
    { "Tier" = "web" },
    { "Application" = format("%s", each.key) },
    each.value.tags
  )
}

# Define listeners
locals {
  listeners = flatten([
    for name, loadbalancer in var.lb : [
      for listener in loadbalancer.listeners : {
        loadbalancer    = name
        port            = (contains(keys(local.protocol_ports), listener.protocol) && (listener.port == null)) ? lookup(local.protocol_ports, listener.protocol) : listener.port
        protocol        = listener.protocol
        default_action  = (listener.default_action == null) ? "forward" : listener.default_action
        tg_name         = (listener.tg_name == null) ? null : listener.tg_name
        ssl_certificate = loadbalancer.ssl_certificate
      }
    ]
  ])
}

# Define default HTTP/TCP listener
resource "aws_lb_listener" "http" {
  for_each = {
    for item in local.listeners : "${item.loadbalancer}_${item.protocol}${item.port}" => item if item.protocol == "HTTP" || item.protocol == "TCP"
  }
  load_balancer_arn = aws_lb.lb[each.value.loadbalancer].arn
  port              = each.value.port
  protocol          = each.value.protocol

  timeouts {}

  lifecycle {
    ignore_changes = [tags, tags_all]
  }

  default_action {
    type             = each.value.default_action
    target_group_arn = (each.value.tg_name == null) ? null : aws_lb_target_group.tg[each.value.tg_name].arn

    dynamic "redirect" {
      for_each = (each.value.default_action == "redirect") ? [each.value] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }


    dynamic "fixed_response" {
      for_each = (each.value.default_action == "fixed-response") ? [each.value] : []
      content {
        content_type = "text/plain"
        message_body = "path not found"
        status_code  = "503"
      }
    }
  }
}

# Define l_rules for http
locals {
  http_l_rules = flatten([
    for name, loadbalancer in var.lb : [
      for rule in loadbalancer.listener_rules["http"] : {
        loadbalancer  = name
        listener_port = (loadbalancer.listeners[0].port == null) ? local.protocol_ports["HTTP"] : loadbalancer.listeners[0].port
        priority      = rule.priority
        action        = rule.action
        host_header   = contains(keys(rule), "host_header") ? rule.host_header : null
        path_pattern  = contains(keys(rule), "path_pattern") ? rule.path_pattern : null
        source_ip     = contains(keys(rule), "source_ip") ? rule.source_ip : null
        tg_name       = contains(keys(rule), "tg_name") ? rule.tg_name : null
      }
      if length(loadbalancer.listener_rules["http"]) > 0
    ]
    if loadbalancer.listener_rules != null
  ])
}

resource "aws_alb_listener_rule" "http" {
  for_each = {
    for item in local.http_l_rules : "${item.loadbalancer}_HTTP${item.listener_port}_${item.priority}" => item
  }
  listener_arn = aws_lb_listener.http["${each.value.loadbalancer}_HTTP${each.value.listener_port}"].arn
  priority     = each.value.priority

  lifecycle {
    ignore_changes = [priority, tags, tags_all]
  }

  # Redirect actions
  dynamic "action" {
    for_each = (each.value.action == "redirect") ? [each.value] : []

    content {
      type = "redirect"
      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  # fixed-response actions
  dynamic "action" {
    for_each = (each.value.action == "fixed-response") ? [each.value] : []

    content {
      type = "fixed-response"
      fixed_response {
        content_type = "text/plain"
        message_body = "path not found"
        status_code  = "503"
      }
    }
  }

  # forward actions
  dynamic "action" {
    for_each = (each.value.action == "forward") ? [each.value] : []

    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.tg[each.value.tg_name].arn
    }
  }

  # Path Pattern condition
  dynamic "condition" {
    for_each = (each.value.path_pattern == null) ? [] : each.value.path_pattern

    content {
      path_pattern {
        values = each.value.path_pattern
      }
    }
  }

  # Host header condition
  dynamic "condition" {
    for_each = (each.value.host_header == null) ? [] : each.value.host_header

    content {
      host_header {
        values = each.value.host_header
      }
    }
  }

  # Source IP address condition
  dynamic "condition" {
    for_each = (each.value.source_ip == null) ? [] : each.value.source_ip

    content {
      source_ip {
        values = each.value.source_ip
      }
    }
  }
}

# Define default HTTPS/TLS listener
resource "aws_lb_listener" "https" {
  for_each = {
    for item in local.listeners : "${item.loadbalancer}_${item.protocol}${item.port}" => item if item.protocol == "HTTPS" || item.protocol == "TLS"
  }
  load_balancer_arn = aws_lb.lb[each.value.loadbalancer].arn
  port              = each.value.port
  protocol          = each.value.protocol
  certificate_arn   = data.aws_acm_certificate.lb_ssl[each.value.ssl_certificate[0]].arn
  ssl_policy        = local.listener_ssl_policy
  alpn_policy       = (each.value.protocol == "TLS") ? local.alpn_policy : null

  timeouts {}

  lifecycle {
    ignore_changes = [ssl_policy, tags, tags_all]
  }

  default_action {
    type             = each.value.default_action
    target_group_arn = (each.value.tg_name == null) ? null : aws_lb_target_group.tg[each.value.tg_name].arn


    dynamic "fixed_response" {
      for_each = (each.value.default_action == "fixed-response") ? [each.value] : []
      content {
        content_type = "text/plain"
        message_body = "path not found"
        status_code  = "503"
      }
    }
  }
}

# Define l_rules for https
locals {
  https_l_rules = flatten([
    for name, loadbalancer in var.lb : [
      for rule in loadbalancer.listener_rules["https"] : {
        loadbalancer  = name
        listener_port = local.protocol_ports["HTTPS"]
        priority      = rule.priority
        action        = rule.action
        host_header   = contains(keys(rule), "host_header") ? rule.host_header : null
        path_pattern  = contains(keys(rule), "path_pattern") ? rule.path_pattern : null
        source_ip     = contains(keys(rule), "source_ip") ? rule.source_ip : null
        tg_name       = contains(keys(rule), "tg_name") ? rule.tg_name : null
      }
      if length(loadbalancer.listener_rules["https"]) > 0
    ]
    if loadbalancer.listener_rules != null
  ])
}

resource "aws_lb_listener_rule" "https" {
  for_each = {
    for item in local.https_l_rules : "${item.loadbalancer}_HTTPS${item.listener_port}_${item.priority}" => item
  }
  listener_arn = aws_lb_listener.https["${each.value.loadbalancer}_HTTPS${each.value.listener_port}"].arn
  priority     = each.value.priority

  lifecycle {
    ignore_changes = [priority, tags, tags_all]
  }

  # fixed-response actions
  dynamic "action" {
    for_each = (each.value.action == "fixed-response") ? [each.value] : []

    content {
      type = "fixed-response"
      fixed_response {
        content_type = "text/plain"
        message_body = "path not found"
        status_code  = "503"
      }
    }
  }

  # forward actions
  dynamic "action" {
    for_each = (each.value.action == "forward") ? [each.value] : []

    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.tg[each.value.tg_name].arn
    }
  }

  # Path Pattern condition
  dynamic "condition" {
    for_each = (each.value.path_pattern == null) ? [] : each.value.path_pattern

    content {
      path_pattern {
        values = each.value.path_pattern
      }
    }
  }

  # Host header condition
  dynamic "condition" {
    for_each = (each.value.host_header == null) ? [] : each.value.host_header

    content {
      host_header {
        values = each.value.host_header
      }
    }
  }

  # Source IP address condition
  dynamic "condition" {
    for_each = (each.value.source_ip == null) ? [] : each.value.source_ip

    content {
      source_ip {
        values = each.value.source_ip
      }
    }
  }
}

# Route53 zone data gathering
data "aws_route53_zone" "lb_dns" {
  name         = local.dns_name
  private_zone = true
}

locals {
  dns_list = flatten([for lb, records in var.lb_dns : [
    for cname in records : { key = tostring(cname), value = lb }
    ]
  ])
  dns_map = { for item in local.dns_list : item.key => item.value }

  dns_list_pub = flatten([for lb, records in var.lb_dns_pub : [
    for cname in records : { key = tostring(cname), value = lb }
    ]
  ])
  dns_map_pub = { for item in local.dns_list_pub : item.key => item.value }  
}

resource "aws_route53_record" "lb_dns" {
  for_each = local.dns_map
  zone_id  = data.aws_route53_zone.lb_dns.zone_id
  name     = each.key
  type     = "A"

  alias {
    name                   = aws_lb.lb[each.value].dns_name
    zone_id                = aws_lb.lb[each.value].zone_id
    evaluate_target_health = false
  }

  lifecycle {
    ignore_changes = [alias]
  }
}

data "aws_route53_zone" "lb_dns_pub" {
  name         = local.dns_name
  private_zone = false
}

resource "aws_route53_record" "lb_dns_pub" {
  for_each = local.dns_map_pub
  zone_id  = data.aws_route53_zone.lb_dns_pub.zone_id
  name     = each.key
  type     = "A"

  alias {
    name                   = aws_lb.lb[each.value].dns_name
    zone_id                = aws_lb.lb[each.value].zone_id
    evaluate_target_health = false
  }

  lifecycle {
    ignore_changes = [alias]
  }
}

