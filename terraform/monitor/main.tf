module "dd-alert" {
  source       = "gitlab.com/11671/dd-alert/local"
  env          = var.env
  opsgenie_tag = var.opsgenie_tag
  org          = var.team_name
  service      = var.service_name
  url          = var.url
  threshold    = var.monitor_threshold
}
