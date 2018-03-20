provider "aws" {
  profile = "${var.deploy_profile}"
  region  = "${var.aws_region}"
}

module "nomad-infra" {
  source     = "../../"
  aws_region = "${var.aws_region}"
}
