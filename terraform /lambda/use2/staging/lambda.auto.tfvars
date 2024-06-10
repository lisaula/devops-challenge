lambda = {
  # ---------- LAMBDA FUNCTIONS ----------
  "devops-function-lambda" = {
    function_name = "devops-challenge-function-staging"
    description   = "Devops Challenge - Staging"
    role          = "devops-challenge-function-role"
    create_role = true
    handler       = "index.handler"
    package_type  = "Zip"
    runtime       = "nodejs20.x"
    memory_size   = 512
    timeout       = 10
    image_uri     = null
    environment   = {}
    vpc_config    = false
    tags          = {}
  }

}

