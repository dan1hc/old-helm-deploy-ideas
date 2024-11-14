terraform {
    backend "s3" {}
    required_providers {
        datadog        = {
            source        = "DataDog/datadog"
            version       = "3.17.0"
        }
        gitlab         = {
            source        = "gitlabhq/gitlab"
            version       = "3.16.1"
        }
    }
}

provider "gitlab" {
  token                = var.token
}

provider "datadog" {
  api_key              = var.datadog_api_key
  app_key              = var.datadog_app_key
}
