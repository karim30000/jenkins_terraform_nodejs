variable "db_name" {}

variable "username" {}

variable "password" {}

variable "rds_name" {}

variable "rds_sg_tag" {}

variable "vpc-id" {}

variable "private-subnet-ids" {
  type = list(string)
}

variable "private-subnet-cidrs" {
  type = list(string)
}
