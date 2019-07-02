# Spoke Variables
# 
# Customize these for your Spoke deployment.
# 
# Source: https://www.terraform.io/intro/getting-started/variables.html

variable "client_name_friendly" {
  type        = "string"
  description = "Human-readable client name to use in resource Name tags."
}

# #######################
# AWS Variables
# #######################

# -----------------------
# General
# -----------------------

variable "aws_region" {
  type        = "string"
  description = "AWS region to launch servers. Ex. us-east-1"
  default     = "us-east-2"
}

variable "base_domain" {
  type        = "string"
  description = "The base domain that Spoke components will be running on. Ex. spoke.client.politicsrewired.dev"
}

# -----------------------
# Billing
# -----------------------

variable "aws_client_tag" {
  type        = "string"
  description = "The value for AWS cost allocation tag `user:client`."
}

variable "aws_stack_tag" {
  type        = "string"
  description = "The value for AWS cost allocation tag `user:stack`."
  default     = "production"
}

# -----------------------
# S3
# -----------------------

variable "s3_bucket_name" {
  type        = "string"
  description = "Create a globally unique S3 bucket. Usually the same as spoke_domain: spoke.example.com"
}

# -----------------------
# RDS
# -----------------------

variable "rds_dbname" {
  type        = "string"
  description = "The DB name for the Postgres instance."
  default     = "spoke"
}

variable "rds_username" {
  type        = "string"
  description = "The username for the Postgres instance."
}

variable "rds_password" {
  type        = "string"
  description = "The password for the Postgres instance user."
}

variable "engine_mode" {
  type        = "string"
  description = "The database engine mode. Valid values: global, parallelquery, provisioned, and serverless"
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

variable "db_parameter_group_name" {
  type        = "string"
  description = "A parameter group to associate with the cluster."
  default     = "default.aurora-postgresql10"
}

variable "aurora_instance_count" {
  type        = "string"
  description = "The number of DB instances to create in the cluster."
  default     = 1
}

variable "aurora_instance_class" {
  type        = "string"
  description = "The instance class to use. For details on CPU and memory, see Scaling Aurora DB Instances. Aurora uses db.* instance classes/types."
  default     = "db.t3.medium"
}

variable "aurora_publicly_accessible" {
  type        = "string"
  description = "Bool to control if instance is publicly accessible. Default true."
  default     = true
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

# -----------------------
# Elastic Beanstalk
# -----------------------

variable "ssh_key_name" {
  type        = "string"
  description = "Name of SSH Key to use for Elastic Beanstalk EC2 instances."
}

variable "enable_https" {
  type        = "string"
  default     = "true"
  description = "Enable or disable HTTPS connection on port 443."
}

variable "loadbalancer_ssl_policy" {
  type        = "string"
  description = "Specify a security policy to apply to the listener. This option is only applicable to environments with an application load balancer."
  default     = "ELBSecurityPolicy-2016-08"
}

variable "eb_solution_stack_name" {
  type        = "string"
  default     = "64bit Amazon Linux 2018.03 v4.9.2 running Node.js"
  description = "The Elastic Beanstalk solution stack name"
}

# ###########################
# Spoke Environment Variables
# ###########################

# -----------------------
# General Spoke
# -----------------------

variable "spoke_domain" {
  type        = "string"
  description = "The domain that Spoke will be running on. Ex. spoke.example.com"
}

variable "spoke_suppress_seed" {
  type        = "string"
  description = "Prevent seed calls from being run automatically."
  default     = "1"
}

variable "spoke_suppress_self_invite" {
  type        = "string"
  description = "Prevent users from being able to create organizations."
  default     = "1"
}

variable "spoke_session_secret" {
  type        = "string"
  description = "Session secret."
}

variable "spoke_timezone" {
  type        = "string"
  description = "Timezone that Spoke is operating in."
  default     = "America/New_York"
}

variable "spoke_lambda_debug" {
  type        = "string"
  description = "Lambda debug flag."
  default     = "0"
}

variable "spoke_external_faq_url" {
  type        = "string"
  description = "When set, the 'Have you checked the FAQ?'' text in the Escalate Conversation flow will link to this page. When unset, the text will be static."
  default     = ""
}

# -----------------------
# SMS Providers
# -----------------------

variable "spoke_default_service" {
  type        = "string"
  description = "The SMS service to use."
  default     = "twilio"
}

## Twilio

variable "spoke_twilio_account_sid" {
  type        = "string"
  description = "Twilio Account SID."
  default     = ""
}

variable "spoke_twilio_auth_token" {
  type        = "string"
  description = "Twilio auth token."
  default     = ""
}

variable "spoke_twilio_message_service_sid" {
  type        = "string"
  description = "Twilio Message Service SID."
  default     = ""
}

variable "spoke_twilio_validation_host" {
  type        = "string"
  description = "Allow overriding the host Spoke validates Twilio headers against."
  default     = ""
}

variable "spoke_skip_twilio_validation" {
  type        = "string"
  description = "Whether to skip validating inbound requests from Twilio."
  default     = "false"
}

## Nexmo

variable "spoke_nexmo_api_key" {
  type        = "string"
  description = "Nexmo API key."
  default     = ""
}

variable "spoke_nexmo_api_secret" {
  type        = "string"
  description = "Nexmo API secret."
  default     = ""
}

# -----------------------
# Authentication
# -----------------------

variable "spoke_passport_strategy" {
  type        = "string"
  description = "Passport strategy to use."
  default     = "auth0"
}

# Slack

variable "spoke_slack_client_id" {
  type        = "string"
  description = "Slack client ID."
  default     = ""
}

variable "spoke_slack_client_secret" {
  type        = "string"
  description = "Slack client secret."
  default     = ""
}

variable "spoke_slack_team_name" {
  type        = "string"
  description = "Slack team name."
  default     = ""
}

# Auth0

variable "spoke_auth0_domain" {
  type        = "string"
  description = "Auth0 domain."
  default     = "domain.auth0.com"
}

variable "spoke_auth0_client_id" {
  type        = "string"
  description = "Auth0 client ID."
  default     = ""
}

variable "spoke_auth0_client_secret" {
  type        = "string"
  description = "Auth0 client secret."
  default     = ""
}

# -----------------------
# Email
# -----------------------

variable "spoke_email_from" {
  type        = "string"
  description = "Address to send emails from."
  default     = ""
}

## SMTP

variable "spoke_email_host" {
  type        = "string"
  description = "Email host."
  default     = ""
}

variable "spoke_email_host_port" {
  type        = "string"
  description = "Email host port."
  default     = ""
}

variable "spoke_email_host_user" {
  type        = "string"
  description = "Email host username."
  default     = ""
}

variable "spoke_email_host_password" {
  type        = "string"
  description = "Email host password."
  default     = ""
}

## Mailgun

variable "spoke_mailgun_api_key" {
  type        = "string"
  description = "Mailgun API key."
  default     = ""
}

variable "spoke_mailgun_domain" {
  type        = "string"
  description = "Mailgun domain."
  default     = ""
}

variable "spoke_mailgun_public_key" {
  type        = "string"
  description = "Mailgun public key."
  default     = ""
}

variable "spoke_mailgun_smtp_login" {
  type        = "string"
  description = "Mailgun SMTP login username."
  default     = ""
}

variable "spoke_mailgun_smtp_password" {
  type        = "string"
  description = "Mailgun SMTP login password."
  default     = ""
}

variable "spoke_mailgun_smtp_port" {
  type        = "string"
  description = "Mailgun SMTP port."
  default     = "587"
}

variable "spoke_mailgun_smtp_server" {
  type        = "string"
  description = "Mailgun SMTP host."
  default     = "smtp.mailgun.org"
}

# -----------------------
# Action Handlers
# -----------------------

variable "spoke_action_handlers" {
  type        = "string"
  description = "Enabled Action Handlers."
  default     = ""
}

## ActionKit

variable "spoke_ak_baseurl" {
  type        = "string"
  description = "ActionKit base URL."
  default     = ""
}

variable "spoke_ak_secret" {
  type        = "string"
  description = "ActionKit secret."
  default     = ""
}

# -----------------------
# Rollbar
# -----------------------

variable "spoke_rollbar_client_token" {
  type        = "string"
  description = "Rollbar client token."
  default     = ""
}

variable "spoke_rollbar_endpoint" {
  type        = "string"
  description = "Rollbar endpoint."
  default     = "https://api.rollbar.com/api/1/item/"
}

# ------------------------------
# External Assignment Management
# ------------------------------

## Outgoing

variable "spoke_assignment_requested_token" {
  type        = "string"
  description = "Bearer token for outgoing assignment requests."
  default     = ""
}

variable "spoke_assignment_requested_url" {
  type        = "string"
  description = "Initial outgoing assignment request."
  default     = ""
}

variable "spoke_assignment_complete_url" {
  type        = "string"
  description = "URL to hit when campaign autoassignment completes."
  default     = ""
}

## Incoming

variable "spoke_assignment_username" {
  type        = "string"
  description = "Basic authentication username for incoming assignment approval requests."
  default     = ""
}

variable "spoke_assignment_password" {
  type        = "string"
  description = "Basic authentication password for incoming assignment approval requests."
  default     = ""
}

# --------------------------------------
# External Bad Word Flagging Integration
# --------------------------------------

variable "spoke_bad_word_token" {
  type        = "string"
  description = "Bearer token for outgoing bad word notifications."
  default     = ""
}

variable "spoke_bad_word_url" {
  type        = "string"
  description = "URL for outgoing bad word notifications."
  default     = ""
}
