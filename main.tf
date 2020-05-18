locals {
  team-resources = "0.5.0"
}

resource "kubernetes_namespace" "vault" {
  metadata {

    name = "vault"

    labels = {
      "name" = "vault"
    }

    annotations = {
      "cloud-platform.justice.gov.uk/application"   = "vault"
      "cloud-platform.justice.gov.uk/business-unit" = "cloud-platform"
      "cloud-platform.justice.gov.uk/owner"         = "Cloud Platform: platforms@digital.justice.gov.uk"
      "cloud-platform.justice.gov.uk/source-code"   = "https://github.com/ministryofjustice/cloud-platform-infrastructure"
    }
  }
}

data "helm_repository" "cloud-platform" {
  name = "cloud-platform"
  url  = "https://ministryofjustice.github.io/cloud-platform-helm-charts"
}

resource "helm_release" "vault" {

  name       = "vault"
  chart      = "vault"
  repository = data.helm_repository.cloud-platform.metadata[0].name
  namespace  = var.namespace
  version    = local.team-resources

  values = [templatefile("${path.module}/templates/values.yaml.tpl", {})]

}
