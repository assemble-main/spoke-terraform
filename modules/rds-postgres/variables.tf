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

variable "engine_mode" {
  type        = "string"
  description = "The database engine mode. Valid values: provisioned and serverless"
  default     = "serverless"
}

variable "copy_tags_to_snapshot" {
  type        = "string"
  description = "Copy all Cluster tags to snapshots. Default is true."
  default     = true
}

variable "storage_encrypted" {
  type        = "string"
  description = "Specifies whether the DB cluster is encrypted. Default is true."
  default     = true
}

variable "deletion_protection" {
  type        = "string"
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to true. The default is true."
  default     = true
}

variable "skip_final_snapshot" {
  type        = "string"
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. If false is specified, a DB snapshot is created before the DB cluster is deleted, using the value from final_snapshot_identifier. Default is false."
  default     = false
}

variable "backup_retention_period" {
  type        = "string"
  description = "The days to retain backups for. Default 5."
  default     = 5
}

variable "preferred_backup_window" {
  type        = "string"
  description = "The daily time range during which automated backups are created if automated backups are enabled using the BackupRetentionPeriod parameter.Time in UTC Default: A 30-minute window selected at random from an 8-hour block of time per region. e.g. 04:00-09:00"
  default     = "06:00-11:00" # UTC
}

variable "preferred_maintenance_window" {
  type        = "string"
  description = "The weekly time range during which system maintenance can occur, in (UTC) e.g. wed:04:00-wed:04:30"
  default     = "sat:05:00-sat:05:30" # UTC
}

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

# Serverless

variable "serverless_min_capacity" {
  type        = "string"
  description = "Minimum ACU count for PostgreSQL database."
  default     = 8
}

variable "serverless_max_capacity" {
  type        = "string"
  description = "Minimum ACU count for PostgreSQL database."
  default     = 256
}

# Aurora

# https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.Updates.20180305.html
variable "engine_version" {
  type        = "string"
  description = "The database engine version. Updating this argument results in an outage."
  default     = "10.7"
}

# Serverless PostgreSQL does not support changing cluster paramter groups at this time
variable "db_cluster_parameter_group_name" {
  type        = "string"
  description = "A cluster parameter group to associate with the cluster."
  default     = "default.aurora-postgresql10"
}
