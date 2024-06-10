lb = {
  "devops-challenge-LB" = {
    type                = "application"
    internal            = false
    deletion_protection = true
    preserve_host_header = true
    idle_timeout        = 120
    lb_sg               = "devops-challenge-LB"
    lb_subnets          = ["sn-prv001", "sn-prv002"] # subnet-0867354cb579160d1 subnet-08c5ee22bfd0e3761
    ssl_certificate     = ["*.devops.com"]
    access_logs = {
      enabled = false
    }
    listeners = [
      { protocol = "HTTP", default_action = "redirect" },
      { protocol = "HTTPS", default_action = "fixed-response" }
    ]
    listener_rules = {
      http = []
      https = [
        { priority = 1, action = "forward", host_header = ["devops.com"], tg_name = "devops-admin" },
        { priority = 2, action = "forward", host_header = ["devops.com"], path_pattern = "/api/*", tg_name = "devops-api" },
      ]
    }
    tags = { }
  }
  
}

lb_dns = {
  "devops-challenge-LB"  = ["devosp.com"]
}

lb_dns_pub = {}