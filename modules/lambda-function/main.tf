# Create Lambda Security Group
# Source: https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "lambda" {
  name        = "${var.aws_client_tag}-lambda"
  description = "Allow all inbound web traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = true
    description = "Web traffic"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = true
    description = "Encrypted web traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name               = "${var.client_name_friendly} Spoke Lambda"
    "user:client"      = "${var.aws_client_tag}"
    "user:stack"       = "${var.aws_stack_tag}"
    "user:application" = "spoke"
  }
}

# Create Lambda Role
# Source: https://www.terraform.io/docs/providers/aws/r/iam_role.html
resource "aws_iam_role" "spoke_lambda" {
  name = "${var.aws_client_tag}-SpokeOnLambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Attach Policies to Role
# Source: https://www.terraform.io/docs/providers/aws/r/iam_role_policy_attachment.html

# AWSLambdaRole
resource "aws_iam_role_policy_attachment" "aws_lambda" {
  role = "${aws_iam_role.spoke_lambda.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
}

# AWSLambdaVPCAccessExecutionRole
resource "aws_iam_role_policy_attachment" "aws_lambda_vpc_access_execution" {
  role = "${aws_iam_role.spoke_lambda.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# S3 Bucket Access
resource "aws_iam_role_policy_attachment" "s3_bucket_access_attach" {
  role = "${aws_iam_role.spoke_lambda.name}"
  policy_arn = "${var.s3_bucket_access_role_arn}"
}

# Inline Policy
# Source: https://www.terraform.io/docs/providers/aws/r/iam_role_policy.html
resource "aws_iam_role_policy" "vpc_access_execution" {
  name = "vpc-access-execution"
  role = "${aws_iam_role.spoke_lambda.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VPCAccessExecutionPermission",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeNetworkInterfaces"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Create Lambda function
# Source: https://www.terraform.io/docs/providers/aws/r/lambda_function.html
resource "aws_lambda_function" "spoke" {
  function_name = "${var.aws_client_tag}-spoke"
  description   = "Spoke P2P Texting Platform for ${var.client_name_friendly}"

  handler     = "lambda.handler"
  s3_bucket   = "${var.s3_bucket_name}"
  s3_key      = "${var.dummy_payload_key}"
  runtime     = "${var.node_runtime}"
  memory_size = "${var.func_memory_mb}"
  timeout     = "${var.lambda_timeout_s}"

  role = "${aws_iam_role.spoke_lambda.arn}"

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = ["${aws_security_group.lambda.id}"]
  }

  environment {
    variables = {
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
      DB_HOST             = "${var.db_host}"
      DB_PORT             = "${var.db_port}"
      DB_NAME             = "${var.db_name}"
      DB_USER             = "${var.db_user}"
      DB_PASSWORD         = "${var.db_password}"
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

  tags = {
    Name               = "${var.client_name_friendly} Spoke"
    "user:client"      = "${var.aws_client_tag}"
    "user:stack"       = "${var.aws_stack_tag}"
    "user:application" = "spoke"
  }
}
