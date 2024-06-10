terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 4.59.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      "Env"             = terraform.workspace
      "IaaC"            = "terraform"
      "Region"          = "us-east-2"
    }
  }
}

# Backend for tfstate
terraform {
  backend "s3" {
    bucket         = "tfstate-infra"
    encrypt        = true
    key            = "devops/ecs/terraform.tfstate"
    region         = "us-east-2"
  }
}

data "terraform_remote_state" "lb_tg" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    bucket = "tfstate-infra"
    key    = "devops/lb/terraform.tfstate"
    region = "us-east-2"
  }
}

data "terraform_remote_state" "network" {
  backend   = "s3"
  workspace = "prod"
  config = {
    bucket = "tfstate-infra"
    key    = "devops/network/terraform.tfstate"
    region = "us-east-2"
  }
}

data "terraform_remote_state" "sg" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    bucket = "tfstate-infra"
    key    = "devops/sg/sandbox/use2/terraform.tfstate"
    region = "us-east-2"
  }
}
