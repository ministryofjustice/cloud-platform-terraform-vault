# cloud-platform-terraform-vault

Terraform module that deploys cloud-platform's Vault.

## Usage

```hcl
module "vault" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-vault?ref=v0.0.1"
  namespace = "vault"
}
```

## Inputs

| Name                         | Description                                        | Type | Default | Required |
|------------------------------|----------------------------------------------------|:----:|:-------:|:--------:|
| namespace         | Namespace where vault will run                | string   |       | yes |

## Outputs
