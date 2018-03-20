provider "aws" {
  profile = "${var.deploy_profile}"
  region  = "${var.aws_region}"
}

module "networking" {
  source = "../../modules/networking"
  region = "${var.aws_region}"
}
