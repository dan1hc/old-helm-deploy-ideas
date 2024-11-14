terraform {
    backend "s3" {}
    required_providers {
        aws            = {
            source       = "hashicorp/aws"
            version      = ">= 3.40.0"
        }
        gitlab         = {
            source       = "gitlabhq/gitlab"
            version      = "3.16.1"
        }
    }
}

provider "gitlab" {
  token                = var.token
}

provider "aws" {
  region               = var.aws_region
  access_key           = var.aws_access_key_id
  secret_key           = var.aws_secret_access_key
}
