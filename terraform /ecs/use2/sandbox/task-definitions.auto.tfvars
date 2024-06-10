task_definitions = {
  "devops-admin" = {
    cpu           = 256
    memory        = 512
    task_role_arn = "ecsTaskExecutionRole"
    family_name   = "devops-admin"
    port_mappings = {
      HostPort      = 3001,
      ContainerPort = 3001
    }
    environment = {}
    image = "devops-admin:sandbox"
  },
  "devops-api" = {
    cpu           = 256
    memory        = 512
    task_role_arn = "ecsTaskExecutionRole"
    family_name   = "devops-api"
    port_mappings = {
      HostPort      = 3000,
      ContainerPort = 3000
    }
    environment = {}
    image = "devops-api:sandbox"
  },
}
