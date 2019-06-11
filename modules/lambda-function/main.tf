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
    variables = var.spoke_env
  }

  tags = {
    Name               = "${var.client_name_friendly} Spoke"
    "user:client"      = "${var.aws_client_tag}"
    "user:stack"       = "${var.aws_stack_tag}"
    "user:application" = "spoke"
  }
}
