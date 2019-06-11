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

  tags = {
    Name               = "${var.client_name_friendly} Spoke Bucket"
    "user:client"      = "${var.aws_client_tag}"
    "user:stack"       = "${var.aws_stack_tag}"
    "user:application" = "spoke"
  }
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
  dummy_payload_key = "${local.dummy_payload_key}"
  s3_bucket_access_role_arn = "${aws_iam_policy.s3_bucket_access.arn}"

  db_host = "${module.postgres.endpoint}"
  db_port = "${module.postgres.port}"
  db_name = "${module.postgres.database_name}"
  db_user = "${module.postgres.master_username}"
  db_password = "${var.rds_password}"

  spoke_domain = "${var.spoke_domain}"
  spoke_suppress_seed = "${var.spoke_suppress_seed}"
  spoke_suppress_self_invite = "${var.spoke_suppress_self_invite}"
  spoke_session_secret = "${var.spoke_session_secret}"
  spoke_timezone = "${var.spoke_timezone}"
  spoke_lambda_debug = "${var.spoke_lambda_debug}"
  s3_bucket_name = "${var.s3_bucket_name}"

  spoke_default_service = "${var.spoke_default_service}"
  spoke_twilio_account_sid = "${var.spoke_twilio_account_sid}"
  spoke_twilio_auth_token = "${var.spoke_twilio_auth_token}"
  spoke_twilio_message_service_sid = "${var.spoke_twilio_message_service_sid}"
  spoke_nexmo_api_key = "${var.spoke_nexmo_api_key}"
  spoke_nexmo_api_secret = "${var.spoke_nexmo_api_secret}"

  spoke_auth0_domain = "${var.spoke_auth0_domain}"
  spoke_auth0_client_id = "${var.spoke_auth0_client_id}"
  spoke_auth0_client_secret = "${var.spoke_auth0_client_secret}"

  spoke_email_from = "${var.spoke_email_from}"
  spoke_email_host = "${var.spoke_email_host}"
  spoke_email_host_port = "${var.spoke_email_host_port}"
  spoke_email_host_user = "${var.spoke_email_host_user}"
  spoke_email_host_password = "${var.spoke_email_host_password}"
  spoke_mailgun_api_key = "${var.spoke_mailgun_api_key}"
  spoke_mailgun_domain = "${var.spoke_mailgun_domain}"
  spoke_mailgun_public_key = "${var.spoke_mailgun_public_key}"
  spoke_mailgun_smtp_login = "${var.spoke_mailgun_smtp_login}"
  spoke_mailgun_smtp_password = "${var.spoke_mailgun_smtp_password}"
  spoke_mailgun_smtp_port = "${var.spoke_mailgun_smtp_port}"
  spoke_mailgun_smtp_server = "${var.spoke_mailgun_smtp_server}"

  spoke_action_handlers = "${var.spoke_action_handlers}"
  spoke_ak_baseurl = "${var.spoke_ak_baseurl}"
  spoke_ak_secret = "${var.spoke_ak_secret}"

  spoke_rollbar_client_token = "${var.spoke_rollbar_client_token}"
  spoke_rollbar_endpoint = "${var.spoke_rollbar_endpoint}"
}

# API Gateway for Lambda
module "api_gateway" {
  source = "./modules/api-gateway"

  client_name_friendly = "${var.client_name_friendly}"
  aws_client_tag = "${var.aws_client_tag}"
  aws_stack_tag = "${var.aws_stack_tag}"

  invoke_arn = "${module.lambda.invoke_arn}"
  function_arn = "${module.lambda.function_arn}"
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
  ssl_certificate_id = "${data.aws_acm_certificate.spoke_certificate.arn}"
  enable_https = true
  elb_connection_timeout = "120"

  # Security
  vpc_id = "${module.vpc.vpc_id}"
  vpc_subnets = module.vpc.aws_private_subnet_ids
  elb_subnets = module.vpc.aws_public_subnet_ids

  spoke_env = {
    NODE_ENV = "production"
  }
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
