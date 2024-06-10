lb_tg = {
  # ---------- APPLICATION LOAD BALANCERS target groups ----------
  "devops-admin" = {
    target_type          = "ip"
    protocol_port        = "HTTP:3001"
    lb_name              = "devops-challenge-LB"
    deregistration_delay = 30
    health_check = {
      protocol            = "HTTP"
      path                = "/"
      port                = 3001
      healthy_threshold   = 2
      unhealthy_threshold = 3
      timeout             = 75
      interval            = 80
      matcher             = "200-499"
    }
    tags = {}
  },
  "devops-api" = {
    target_type          = "ip"
    protocol_port        = "HTTP:3000"
    lb_name              = "devops-challenge-LB"
    deregistration_delay = 30
    health_check = {
      protocol            = "HTTP"
      path                = "/api/health"
      port                = 3000
      healthy_threshold   = 2
      unhealthy_threshold = 3
      timeout             = 75
      interval            = 80
      matcher             = "200"
    }
    tags = {}
  }
}
