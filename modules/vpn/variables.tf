# -----------------------
# AWS Variables
# -----------------------

variable "client_name_friendly" {
  type        = "string"
  description = "Human-readable client name to use in resource Name tags."
}

variable "aws_client_tag" {
  type        = "string"
  description = "The value for AWS cost allocation tag `user:client`."
}

variable "aws_stack_tag" {
  type        = "string"
  description = "The value for AWS cost allocation tag `user:stack`."
  default     = "production"
}

variable "vpc_id" {
  type        = "string"
  description = "The ID of the VPC to create the Postgres instance within. Example: aws_vpc.spoke_vpc.id"
}

variable "subnet_id" {
  type        = "string"
  description = "Public subnet for the VPN Instance"
}

# -----------------------
# VPN Variables
# -----------------------

variable "ami" {
  type        = "string"
  description = "AMI to be used, default is Ubuntu 18.67 Bionic"
  default     = "ami-090f10efc254eaf55"
}

variable "instance_type" {
  type        = "string"
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "ssh_key_name" {
  type        = "string"
  description = "The EC2 SSH KeyPair Name"
}
