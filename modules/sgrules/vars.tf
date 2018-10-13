#### Required Variables ############################################
variable "sg_id_public_services_dc" {
  description = "Security-Group ID of the public-service dc."
}
variable "sg_id_private_services_dc" {
  description = "Security-Group ID of the private-service dc."
}
variable "sg_id_content_connector_dc" {
  description = "Security-Group ID of the content-connector dc."
}
variable "sg_id_backoffice_dc" {
  description = "Security-Group ID of the backoffice dc."
}

variable "sg_id_consul" {
  description = "Security-Group ID of the consul nodes."
}

variable "sg_id_nomad_server" {
  description = "Security-Group ID of the nomad server."
}
