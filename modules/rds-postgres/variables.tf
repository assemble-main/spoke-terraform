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

variable "subnet_ids" {
  type        = "list"
  description = "A list of subnet IDs to add the Postgres instance to."
}

# -----------------------
# Database Variables
# -----------------------

variable "rds_dbname" {
  type        = "string"
  description = "The DB name for the Postgres instance."
}

variable "rds_username" {
  type        = "string"
  description = "The username for the Postgres instance."
}

variable "rds_password" {
  type        = "string"
  description = "The password for the Postgres instance user."
}

variable "rds_min_capacity" {
  type        = "string"
  description = "Minimum ACU count for PostgreSQL database."
  default     = 8
}

variable "rds_max_capacity" {
  type        = "string"
  description = "Minimum ACU count for PostgreSQL database."
  default     = 256
}
