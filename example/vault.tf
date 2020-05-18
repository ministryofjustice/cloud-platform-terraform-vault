providers = {
  # Can be either "aws.london" or "aws.ireland"
  aws = aws.london
}

module "vault" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-vault?ref=v1.0"
  namespace = "vault"
}