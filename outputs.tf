# Spoke Deployment Output
# 
# Print information about the resources created. These values will be needed
# in the Claudia.js deploy command.
# 
# Source: https://www.terraform.io/intro/getting-started/outputs.html

# -----------------------
# DNS
# -----------------------

output "lambda_uri" {
  description = "URI for Lambda function."
  value       = "${module.api_gateway.lambda_domain}"
}

output "eb_cname" {
  description = "URI for EB environment."
  value       = "${module.elastic_beanstalk.eb_env_cname}"
}

# -----------------------
# Database
# -----------------------

output "certificate_arn" {
  description = "The ARN of the certificate to use."
  value       = "${data.aws_acm_certificate.spoke_certificate.arn}"
}

output "endpoint" {
  description = "Aurora PostgreSQL DNS endpoint."
  value       = "${module.postgres.endpoint}"
}

output "reader_endpoint" {
  description = "Aurora PostgreSQL DNS read-only endpoint."
  value       = "${module.postgres.reader_endpoint}"
}

output "port" {
  description = "Aurora PostgreSQL port."
  value       = "${module.postgres.port}"
}

output "database_name" {
  description = "Aurora PostgreSQL database name."
  value       = "${module.postgres.database_name}"
}

output "master_username" {
  description = "Aurora PostgreSQL master username."
  value       = "${module.postgres.master_username}"
}
