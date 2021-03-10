
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

  values = [templatefile("${path.module}/templates/values.yaml.tpl", {
    dynamo_table      = module.dynamodb_table.this_dynamodb_table_id
    dynamo_access_key = join("", aws_iam_access_key.vault_dynamodb_user.*.id)
    dynamo_secret_key = join("", aws_iam_access_key.vault_dynamodb_user.*.secret)
    seal_kms          = aws_kms_key.vault_kms.key_id
    seal_access_key   = join("", aws_iam_access_key.vault_kms_user.*.id)
    seal_secret_key   = join("", aws_iam_access_key.vault_kms_user.*.secret)
  })]
}

############
# DynamoDB #
############
module "dynamodb_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name = "vault"

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

  tags = {
    Terraform   = "true"
    Environment = "staging"
  }
}

resource "aws_kms_key" "vault_dynamodb" {
  description = "DynamoDB key for Vault"
}

resource "aws_iam_user" "vault_dynamodb_user" {
  name = "vault_dynamodb_user"
}

resource "aws_iam_access_key" "vault_dynamodb_user" {
  user = aws_iam_user.vault_dynamodb_user.name
}

data "aws_iam_policy_document" "vault_dynamodb_policy" {
  statement {
    actions   = ["dynamodb:*"]
    resources = [module.dynamodb_table.this_dynamodb_table_arn]
  }
}

resource "aws_iam_user_policy" "vault_dynamodb_policy" {
  name   = "vault_kms_policy"
  policy = data.aws_iam_policy_document.vault_dynamodb_policy.json
  user   = aws_iam_user.vault_dynamodb_user.name
}

#########################
# KMS (for auto-unseal) #
#########################

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
