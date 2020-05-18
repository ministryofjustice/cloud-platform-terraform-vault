# cloud-platform-terraform-opa

Terraform module that deploys cloud-platform's open policy agent. It includes all required policies and kubernetes resources in order to get up and running open policy agent in any kops/eks cluster

## Usage

```hcl
module "vault" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opa?ref=0.0.1"
  namespace = "vault"
}
```

## Inputs

| Name                         | Description                                        | Type | Default | Required |
|------------------------------|----------------------------------------------------|:----:|:-------:|:--------:|
| dependence_deploy            | Deploy (helm) dependence variable                  | string   |       | yes |

## Outputs
