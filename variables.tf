variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "ec2name" {
  type    = string
  default = "royston-ec2-ebs"
}

variable "vpc_id" {
  type    = string
  default = "vpc-0488a02e392e3eea1"
}

variable "name" {
  type    = string
  default = "royston"
}

variable "keypair" {
  type    = string
  default = "royston-ec2-keypair"
}
