# Spoke Deployment Output
# 
# Print information about the resources created. These values will be needed
# in the Claudia.js deploy command.
# 
# Source: https://www.terraform.io/intro/getting-started/outputs.html

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
