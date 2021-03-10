terraform {
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"
}

module "vault" {
  source = "../"

}
