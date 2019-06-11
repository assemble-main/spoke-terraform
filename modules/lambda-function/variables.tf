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

# -------------------------
# Lambda Function Variables
# -------------------------

variable "aws_region" {
  type        = "string"
  description = "AWS region to launch servers. Ex. us-east-1"
}

variable "vpc_id" {
  type        = "string"
  description = "ID of the VPC the Spoke function should belong to."
}

variable "subnet_ids" {
  type        = "list"
  description = "IDs of the subnets the Lambda function should belong to."
}

variable "s3_bucket_access_role_arn" {
  type        = "string"
  description = "The ARN of the role allowing access to the S3 bucket."
}

variable "s3_bucket_name" {
  type        = "string"
  description = "The name of the S3 bucket where the server bundle resides."
}

variable "dummy_payload_key" {
  type        = "string"
  description = "Object key of the dummy payload to instantiate the Lambda function with."
}

variable "node_runtime" {
  type        = "string"
  description = "Node JS runtime version."
  default     = "nodejs8.10"
}

variable "func_memory_mb" {
  type        = "string"
  description = "Lambda function memory amount."
  default     = "512"
}

variable "lambda_timeout_s" {
  type        = "string"
  description = "Lambda timeout in seconds."
  default     = "300"
}

# ---------------------------
# Spoke Environment Variables
# ---------------------------

variable "spoke_env" {
  type        = "map"
  description = "Environment variables for Spoke."
}
