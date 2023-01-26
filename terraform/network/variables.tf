variable "vpc_tag" {}

variable "vpc_cidr" {}

variable "private-subnet_cidrs" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "public-subnet_cidrs" {
  type = list(string)
}