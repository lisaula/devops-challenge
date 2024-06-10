terraform {
  required_version = "= 1.5.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }
  }
}

#Backend for tfstate
terraform {
  backend "s3" {
    bucket         = "tfstate-infra"
    encrypt        = true
    key            = "devops-challenge/lambda/use1/dev.tfstate"
    dynamodb_table = "tflock-wgsn-v2"
    region         = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      "Type"        = "lambda"
      "Env"         = terraform.workspace
      "Region"      = "use1"
    }
  }
}

data "terraform_remote_state" "network" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    bucket = "tfstate-infra"
    key    = "devops/network/use1/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "sg" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    bucket = "tfstate-infra"
    key    = "devops/sg/use1/dev.tfstate"
    region = "us-east-1"
  }
}