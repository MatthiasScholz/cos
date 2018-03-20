provider "aws" {
  profile = "${var.deploy_profile}"
  region  = "${var.aws_region}"
}

resource "random_pet" "unicorn" {
  # NOTE: Length 1 used to avoid problems with the different delimiter requierements in AWS. Nevertheless 1 should be enough.
  length = 1
}

module "nomad-infra" {
  source              = "../../"
  aws_region          = "${var.aws_region}"
  ssh_key_name        = "kp-us-east-1-playground-instancekey"
  env_name            = "${var.env_name}"
  unique_postfix      = "${random_pet.unicorn.id}"
  nomad_cluster_name  = "${var.nomad_cluster_name}"
  consul_cluster_name = "${var.consul_cluster_name}"
}
