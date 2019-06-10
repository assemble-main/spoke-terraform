# -----------------------
# AWS Deploy Variables
# -----------------------

variable "client_name_friendly" {
  type        = "string"
  description = "Human-readable client name to use in resource Name tags."
}

variable "aws_region" {
  type        = "string"
  description = "AWS region to launch servers. Ex. us-east-1"
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

variable "slash_16_cidr_block" {
  type        = "string"
  description = "A /16 CIDR block to use for the VPC."
  default     = "10.0.0.0/16"
}
