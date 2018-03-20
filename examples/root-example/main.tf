provider "aws" {
  profile = "${var.deploy_profile}"
  region  = "${var.aws_region}"
}

module "nomad-infra" {
  source        = "../../"
  aws_region    = "${var.aws_region}"
  nomad_ami_id  = "ami-f7adae8d"
  consul_ami_id = "ami-f7adae8d"
  ssh_key_name  = "kp-us-east-1-playground-instancekey"
}
