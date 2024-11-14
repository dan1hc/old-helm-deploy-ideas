module "ecr-repo" {
  source          = "gitlab.com/1howardcapital/ecr-repo/local"
  repo_name       = "${var.service_name}-${var.env}"
  worker_role_arn = data.terraform_remote_state.eks.outputs.worker_iam_role_arn
}

module "tls-cert" {
  source    = "gitlab.com/1howardcapital/tls-cert/local"
  url       = var.url
  zone_name = "${var.company}.com"
}

module "tls-cert-www" {
  source    = "gitlab.com/1howardcapital/tls-cert/local"
  url       = "www.${var.url}"
  zone_name = "${var.company}.com"
}

data "template_file" "values" {
  template      = file("values.tpl")
  vars          = {
    COMPANY              = var.company
    SERVICE_NAME         = var.service_name
    ENV                  = var.env
    REPLICA_DESIRED      = var.replica_desired
    REPLICA_MIN          = var.replica_min
    REPLICA_MAX          = var.replica_max
    REGISTRY_URL         = "${var.registry}/${var.service_name}-${var.env}"
    IMAGE_TAG            = var.image_tag
    CPU                  = var.cpu
    MEMORY               = var.memory
    DD_METRIC_NAME       = "${var.service_name}-metric"
    SCALE_THRESHOLD      = var.scale_threshold
    SCAN_UP_FREQ         = var.scan_up_freq
    SCAN_DOWN_FREQ       = var.scan_down_freq
    SECURITY_GROUP       = var.security_group
    STAGGER_DOWN_FREQ    = var.stagger_down_freq
    TLS_CERT_ARN         = module.tls-cert.cert_arn
    TLS_CERT_WWW_ARN     = module.tls-cert-www.cert_arn
    HOST_NAME            = var.url
  }
}

resource "local_file" "values" {
    content  = data.template_file.values.rendered
    filename = "helm/values.yaml"
}

data "template_file" "chart" {
  template      = file("chart.tpl")
  vars          = {
    SERVICE_NAME         = var.service_name
    CHART_VERSION        = var.chart_version
  }
}

resource "local_file" "chart" {
    content  = data.template_file.chart.rendered
    filename = "helm/Chart.yaml"
}
