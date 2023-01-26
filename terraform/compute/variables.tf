variable "bastion_avail_zone" {}

variable "bastion_pub_subnet_id" {}

variable "instance_type" {}

variable "key_name" {}

variable "vpc_id" {}

variable "vpc_cidr" {}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "bastion_pub_subnet_cidr" {
  type = list(string)
}
