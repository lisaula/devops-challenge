output "loadbalancers" {
    value = { for name, lb in aws_lb.lb : name => lb.id }
}
output "target_groups" {
  value = { for name, tg in aws_lb_target_group.tg : name => tg.id }
}

output "dns_names" {
  value = { for name, lb in local.dns_map : name => aws_lb.lb[lb].dns_name}
}