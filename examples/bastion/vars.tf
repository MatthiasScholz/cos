variable "deploy_profile" {
  description = "Specify the local AWS profile configuration to use."
}

variable "ssh_key_name" {
  description = "Name of the SSH instance key to be used."
  default = "kp-us-east-1-playground-instancekey"
}
