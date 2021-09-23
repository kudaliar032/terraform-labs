variable "aws_region" {
  type = string
  default = "ap-southeast-1"
}

variable "aws_azs" {
  type = list(string)
  default = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

variable "aws_machine_type" {
  type = string
  default = "t2.micro"
}

variable "cluster_name" {
  type = string
  default = "k0s-cluster"
}

variable "ssh_public_key" {
  type = string
  sensitive = true
}
