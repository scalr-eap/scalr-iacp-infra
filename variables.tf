variable "region" {
  description = "The AWS Region to deploy in"
  type = string
}

variable "instance_type" {
  description = "Instance type must have minimum of 16GB ram and 50GB disk"
  type = string
}

variable "ssh_key_name" {
  description = "The name of then public SSH key to be deployed to the servers. This must exist in AWS already"
  type = string
}

variable "ssh_private_key" {
  description = "The text of SSH Private key. This will be formatted by the Terraform template.<br>This will be used in the remote workspace to allow Terraform to connect to the servers and run scripts to configure Scalr. It only exists in the workspace for the duration of the run."
  type = string
  default = "FROM_FILE"
}

variable "vpc" {
  type = string
}

variable "subnet" {
  type = string
  }

variable "name_prefix" {
  description = "1-3 char prefix for instance names"
  type = string
}
