output "target_groups" {
  value = module.alb.target_groups
}

output "loadbalancers" {
  value = module.alb.loadbalancers
}

output "dns_names" {
  value = module.alb.dns_names
}