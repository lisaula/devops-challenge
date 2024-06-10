service_definitions = {
  "devops-admin" = {
    target_group     = "devops-admin"
    desired_count    = 1
    assign_public_ip = "false"
    container_port   = 3001
    svc_subnets      = ["sn-prv001", "sn-prv002"]
    security_groups  = ["devops-ecs"]
    grace_period     = 0 
    cluster_name     = "sandbox-ecs001"
    name             = "devops-admin"
  },
  "devops-api" = {
    target_group     = "devops-api"
    desired_count    = 1
    assign_public_ip = "false"
    container_port   = 3000
    svc_subnets      = ["sn-prv001", "sn-prv002"]
    security_groups  = ["cfi-ecs"]
    grace_period     = 0 #10
    cluster_name     = "sandbox-ecs001"
    name             = "devops-api"
  }
}
