
resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"

    labels = {
      "component" = "vault"
    }

    annotations = {
      "cloud-platform.justice.gov.uk/application"                = "Vault"
      "cloud-platform.justice.gov.uk/business-unit"              = "Platforms"
      "cloud-platform.justice.gov.uk/owner"                      = "Cloud Platform: platforms@digital.justice.gov.uk"
      "cloud-platform.justice.gov.uk/source-code"                = "https://github.com/ministryofjustice/cloud-platform-infrastructure"
      "iam.amazonaws.com/permitted"                              = ".*"
      "cloud-platform.justice.gov.uk/can-tolerate-master-taints" = "true"
      "cloud-platform-out-of-hours-alert"                        = "true"

    }
  }
}

resource "helm_release" "vault" {
  name      = "vault"
  chart     = "hashicorp/vault"
  namespace = kubernetes_namespace.vault.id

  values = [templatefile("${path.module}/values-vault.yaml", {
    dynamo_table      = module.vault_dynamodb.table_name
    dynamo_access_key = module.vault_dynamodb.access_key_id
    dynamo_secret_key = module.vault_dynamodb.secret_access_key
    seal_kms          = aws_kms_key.vault_kms.key_id
    seal_access_key   = join("", aws_iam_access_key.vault_kms_user.*.id)
    seal_secret_key   = join("", aws_iam_access_key.vault_kms_user.*.secret)
  })]
}

resource "aws_kms_key" "vault_kms" {
  description = "KMS key for Vault"
}

resource "aws_iam_user" "vault_kms_user" {
  name = "vault_kms_user"
}

resource "aws_iam_access_key" "vault_kms_user" {
  user = aws_iam_user.vault_kms_user.name
}

data "aws_iam_policy_document" "vault_policy" {
  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = [
      "${aws_kms_key.vault_kms.arn}"
    ]
  }
}

resource "aws_iam_user_policy" "vault_kms_policy" {
  name   = "vault_kms_policy"
  policy = data.aws_iam_policy_document.vault_policy.json
  user   = aws_iam_user.vault_kms_user.name
}

resource "kubernetes_secret" "vault_kms" {
  metadata {
    name      = "vault-kms"
    namespace = kubernetes_namespace.vault.id
  }

  data = {
    kms_id            = aws_kms_key.vault_kms.key_id
    access_key_id     = join("", aws_iam_access_key.vault_kms_user.*.id)
    secret_access_key = join("", aws_iam_access_key.vault_kms_user.*.secret)
  }
}


module "vault_dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=3.1.3"

  team_name              = "example-team"
  business-unit          = "example-bu"
  application            = "exampleapp"
  is-production          = "false"
  environment-name       = "development"
  infrastructure-support = "example-team@digtal.justice.gov.uk"
  aws_region             = "eu-west-1"
  namespace              = "vault"

  hash_key  = "Path"
  range_key = "Key"
  attributes = [
    {
      name = "Path"
      type = "S"
    },
    {
      name = "Key"
      type = "S"
    }
  ]
}

resource "kubernetes_secret" "vault_dynamodb" {
  metadata {
    name      = "vault-dynamodb"
    namespace = kubernetes_namespace.vault.id
  }

  data = {
    table_name        = module.vault_dynamodb.table_name
    table_arn         = module.vault_dynamodb.table_arn
    access_key_id     = module.vault_dynamodb.access_key_id
    secret_access_key = module.vault_dynamodb.secret_access_key
  }
}
