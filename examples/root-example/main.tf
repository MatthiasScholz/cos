provider "aws" {
  profile = "${var.deploy_profile}"
  region  = "${var.aws_region}"
}

module "nomad-infra" {
  source        = "../../"
  aws_region    = "${var.aws_region}"
  nomad_ami_id  = "ami-1cec3961"
  consul_ami_id = "ami-1cec3961"
  ssh_key_name  = "kp-us-east-1-playground-instancekey"
}
