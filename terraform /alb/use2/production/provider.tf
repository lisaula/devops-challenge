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
      "Region"          = "eu-central-1"
    }
  }
}

# Backend for tfstate
terraform {
  backend "s3" {
    bucket         = "tfstate-infra"
    encrypt        = true
    key            = "devops/lb/terraform.tfstate"
    region         = "eu-central-1"
  }
}

data "terraform_remote_state" "network" {
  backend   = "s3"
  workspace = "prod"
  config = {
    bucket = "tfstate-infra"
    key    = "devops/network/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "terraform_remote_state" "sg" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    bucket = "tfstate-infra"
    key    = "devops/sg/prod/euc1/terraform.tfstate"
    region = "eu-central-1"
  }
}
