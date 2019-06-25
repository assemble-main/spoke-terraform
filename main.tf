# Spoke on AWS
# 
# This will automate creation of resources for running Spoke on AWS. This only
# takes care of the resource creation listed in the first section of the AWS
# Deploy guide (docs/DEPLOYING_AWS_LAMBDA.md). It will _not_ actually deploy
# the code.
# 
# Author: @bchrobot <benjamin.blair.chrobot@gmail.com>
# Version 0.1.0

locals {
  dummy_payload_key = "spoke/deploy/dummy-payload.zip"
  spoke_env = {
    NODE_ENV                     = "production"
    JOBS_SAME_PROCESS            = "1"
    BASE_URL                     = "https://${var.spoke_domain}"
    SESSION_SECRET               = "${var.spoke_session_secret}"
    SUPPRESS_DATABASE_AUTOCREATE = "true"
    SUPPRESS_MIGRATIONS          = "true"
    SUPPRESS_SEED_CALLS          = "${var.spoke_suppress_seed}"
    SUPPRESS_SELF_INVITE         = "${var.spoke_suppress_self_invite}"
    DST_REFERENCE_TIMEZONE       = "${var.spoke_timezone}"
    TZ                           = "${var.spoke_timezone}"
    APOLLO_OPTICS_KEY            = ""
    EXTERNAL_FAQ_URL             = "${var.spoke_external_faq_url}"

    # AWS
    LAMBDA_DEBUG_LOG     = "${var.spoke_lambda_debug}"
    AWS_ACCESS_AVAILABLE = "1"
    AWS_S3_BUCKET_NAME   = "${var.s3_bucket_name}"
    AWS_S3_KEY_PREFIX    = "spoke/exports/"
    STATIC_BASE_URL      = "https://s3.${var.aws_region}.amazonaws.com/${var.s3_bucket_name}/spoke/static/"
    S3_STATIC_PATH       = "s3://${var.s3_bucket_name}/spoke/static/"

    # Build vars
    OUTPUT_DIR      = "./build"
    PUBLIC_DIR      = "./build/client"
    ASSETS_DIR      = "./build/client/assets"
    ASSETS_MAP_FILE = "assets.json"

    # Database connection
    DB_TYPE             = "pg"
    DB_HOST             = "${module.postgres.endpoint}"
    DB_PORT             = "${module.postgres.port}"
    DB_NAME             = "${module.postgres.database_name}"
    DB_USER             = "${module.postgres.master_username}"
    DB_PASSWORD         = "${var.rds_password}"
    DB_KEY              = ""
    DB_MIN_POOL         = "1"
    DB_MAX_POOL         = "4"
    DB_IDLE_TIMEOUT_MS  = "300"
    DB_REAP_INTERVAL_MS = "150"
    PGSSLMODE           = "require"

    # Auth0
    PASSPORT_STRATEGY   = "${var.spoke_passport_strategy}"
    SLACK_CLIENT_ID     = "${var.spoke_slack_client_id}"
    SLACK_CLIENT_SECRET = "${var.spoke_slack_client_secret}"
    SLACK_TEAM_NAME     = "${var.spoke_slack_team_name}"
    AUTH0_DOMAIN        = "${var.spoke_auth0_domain}"
    AUTH0_CLIENT_ID     = "${var.spoke_auth0_client_id}"
    AUTH0_CLIENT_SECRET = "${var.spoke_auth0_client_secret}"

    # SMS
    DEFAULT_SERVICE            = "${var.spoke_default_service}"
    NEXMO_API_KEY              = "${var.spoke_nexmo_api_key}"
    NEXMO_API_SECRET           = "${var.spoke_nexmo_api_secret}"
    TWILIO_API_KEY             = "${var.spoke_twilio_account_sid}"
    TWILIO_APPLICATION_SID     = "${var.spoke_twilio_message_service_sid}"
    TWILIO_AUTH_TOKEN          = "${var.spoke_twilio_auth_token}"
    TWILIO_STATUS_CALLBACK_URL = "https://${var.spoke_domain}/twilio-message-report"
    TWILIO_VALIDATION_HOST     = "${var.spoke_twilio_validation_host}"
    SKIP_TWILIO_VALIDATION     = "${var.spoke_skip_twilio_validation}"

    # Rollbar
    ROLLBAR_CLIENT_TOKEN = "${var.spoke_rollbar_client_token}"
    ROLLBAR_ACCESS_TOKEN = "${var.spoke_rollbar_client_token}"
    ROLLBAR_ENDPOINT     = "${var.spoke_rollbar_endpoint}"

    # Email
    EMAIL_HOST          = "${var.spoke_email_host}"
    EMAIL_HOST_PASSWORD = "${var.spoke_email_host_password}"
    EMAIL_HOST_USER     = "${var.spoke_email_host_user}"
    EMAIL_HOST_PORT     = "${var.spoke_email_host_port}"
    EMAIL_FROM          = "${var.spoke_email_from}"

    # Mailgun
    MAILGUN_API_KEY       = "${var.spoke_mailgun_api_key}"
    MAILGUN_DOMAIN        = "${var.spoke_mailgun_domain}"
    MAILGUN_PUBLIC_KEY    = "${var.spoke_mailgun_public_key}"
    MAILGUN_SMTP_LOGIN    = "${var.spoke_mailgun_smtp_login}"
    MAILGUN_SMTP_PASSWORD = "${var.spoke_mailgun_smtp_password}"
    MAILGUN_SMTP_PORT     = "${var.spoke_mailgun_smtp_port}"
    MAILGUN_SMTP_SERVER   = "${var.spoke_mailgun_smtp_server}"

    # Action handlers
    ACTION_HANDLERS = "${var.spoke_action_handlers}"
    AK_BASEURL      = "${var.spoke_ak_baseurl}"
    AK_SECRET       = "${var.spoke_ak_secret}"

    # External assignment integration -- outgoing
    ASSIGNMENT_REQUESTED_TOKEN           = "${var.spoke_assignment_requested_token}"
    ASSIGNMENT_REQUESTED_URL             = "${var.spoke_assignment_requested_url}"
    ASSIGNMENT_COMPLETE_NOTIFICATION_URL = "${var.spoke_assignment_complete_url}"

    # External assignment integration -- incoming
    ASSIGNMENT_USERNAME = "${var.spoke_assignment_username}"
    ASSIGNMENT_PASSWORD = "${var.spoke_assignment_password}"

    # External bad word flag integration
    BAD_WORD_TOKEN = "${var.spoke_bad_word_token}"
    BAD_WORD_URL   = "${var.spoke_bad_word_url}"
  }
}

# Lookup the certificate (must be created _before_ running `terraform apply`)
# Source: https://www.terraform.io/docs/providers/aws/d/acm_certificate.html
data "aws_acm_certificate" "spoke_certificate" {
  domain   = "*.${var.base_domain}"
  statuses = ["ISSUED"]
}

# Create the bucket
# Source: https://www.terraform.io/docs/providers/aws/r/s3_bucket.html
resource "aws_s3_bucket" "spoke_bucket" {
  bucket = "${var.s3_bucket_name}"
  acl    = "private"

  tags = "${merge(var.cost_allocation_tags, {
    Name = "${var.client_name_friendly} Spoke Bucket"
  })}"
}

# Created scoped S3 access policy
# Source: https://www.terraform.io/docs/providers/aws/r/iam_role_policy.html
resource "aws_iam_policy" "s3_bucket_access" {
  name        = "s3=${var.s3_bucket_name}"
  description = "Allow access to ${var.s3_bucket_name}."

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutAccountPublicAccessBlock",
                "s3:GetAccountPublicAccessBlock",
                "s3:ListAllMyBuckets",
                "s3:HeadBucket"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.s3_bucket_name}",
                "arn:aws:s3:::${var.s3_bucket_name}/*"
            ]
        }
    ]
}
EOF
}

# Dummy payload
# Source: https://amido.com/blog/terraform-does-not-need-your-code-to-provision-a-lambda-function/

data "archive_file" "dummy_payload" {
  type = "zip"
  output_path = "${path.module}/lambda_function_payload.zip"
  source_dir = "${path.module}/dummy-src"
}

resource "aws_s3_bucket_object" "dummy_payload" {
  bucket = "${aws_s3_bucket.spoke_bucket.id}"
  key = "${local.dummy_payload_key}"
  source = "${path.module}/lambda_function_payload.zip"
}

# Create the VPC
module "vpc" {
  source = "./modules/vpc"

  client_name_friendly = "${var.client_name_friendly}"
  aws_client_tag = "${var.aws_client_tag}"
  aws_stack_tag = "${var.aws_stack_tag}"
  aws_region = "${var.aws_region}"
}

# Postgres RDS instance
module "postgres" {
  source = "./modules/rds-postgres"

  client_name_friendly = "${var.client_name_friendly}"
  aws_client_tag = "${var.aws_client_tag}"
  aws_stack_tag = "${var.aws_stack_tag}"
  vpc_id = "${module.vpc.vpc_id}"
  subnet_ids = module.vpc.aws_public_subnet_ids
  rds_dbname = "${var.rds_dbname}"
  rds_username = "${var.rds_username}"
  rds_password = "${var.rds_password}"
  rds_min_capacity = "${var.rds_min_capacity}"
  rds_max_capacity = "${var.rds_max_capacity}"
}

# Lambda function
module "lambda" {
  source = "./modules/lambda-function"

  client_name_friendly = "${var.client_name_friendly}"
  aws_client_tag = "${var.aws_client_tag}"
  aws_stack_tag = "${var.aws_stack_tag}"

  aws_region = "${var.aws_region}"
  vpc_id = "${module.vpc.vpc_id}"
  subnet_ids = module.vpc.aws_private_subnet_ids
  s3_bucket_name = "${var.s3_bucket_name}"
  dummy_payload_key = "${local.dummy_payload_key}"
  s3_bucket_access_role_arn = "${aws_iam_policy.s3_bucket_access.arn}"

  spoke_env = local.spoke_env
}

# API Gateway for Lambda
module "api_gateway" {
  source = "./modules/api-gateway"

  client_name_friendly = "${var.client_name_friendly}"
  aws_client_tag = "${var.aws_client_tag}"
  aws_stack_tag = "${var.aws_stack_tag}"

  invoke_arn = "${module.lambda.invoke_arn}"
  function_arn = "${module.lambda.function_arn}"

  base_domain = "${var.base_domain}"
  certificate_arn = "${data.aws_acm_certificate.spoke_certificate.arn}"
}

# Add access from Lambda to Postgres
resource "aws_security_group_rule" "allow_lambda_postgres" {
  description = "Postgres access from Lambda."
  security_group_id = "${module.postgres.postgres_security_group_id}"

  type = "ingress"
  from_port = 5432
  to_port = 5432
  protocol = "tcp"
  source_security_group_id = "${module.lambda.lambda_security_group_id}"
}

# Elastic Beanstalk
module "elastic_beanstalk" {
  source = "./modules/elastic-beanstalk"

  client_name_friendly = "${var.client_name_friendly}"
  aws_client_tag = "${var.aws_client_tag}"
  aws_stack_tag = "${var.aws_stack_tag}"

  s3_bucket_access_role_arn = "${aws_iam_policy.s3_bucket_access.arn}"

  # Instance settings
  instance_type = "t3.small"
  ssh_key_name = "${var.ssh_key_name}"
  min_instance = "1"
  max_instance = "4"

  # ELB
  ssl_certificate_arn = "${data.aws_acm_certificate.spoke_certificate.arn}"
  enable_https = true
  elb_connection_timeout = "120"

  # Security
  vpc_id = "${module.vpc.vpc_id}"
  vpc_subnets = module.vpc.aws_private_subnet_ids
  elb_subnets = module.vpc.aws_public_subnet_ids

  spoke_env = local.spoke_env
}

# Add access from Elastic Beanstalk to Postgres
resource "aws_security_group_rule" "allow_eb_postgres" {
  description = "Postgres access from Elastic Beanstalk."
  security_group_id = "${module.postgres.postgres_security_group_id}"

  type = "ingress"
  from_port = 5432
  to_port = 5432
  protocol = "tcp"
  source_security_group_id = "${module.elastic_beanstalk.eb_ec2_security_group_id}"
}
