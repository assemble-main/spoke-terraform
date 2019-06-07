# Security Groups

output "postgres_security_group_id" {
  description = "Group ID of the Postgres security group."
  value       = "${aws_security_group.postgres.id}"
}

# Database

output "endpoint" {
  value = "${aws_rds_cluster.spoke.endpoint}"
}

output "reader_endpoint" {
  value = "${aws_rds_cluster.spoke.reader_endpoint}"
}

output "port" {
  value = "${aws_rds_cluster.spoke.port}"
}

output "database_name" {
  value = "${aws_rds_cluster.spoke.database_name}"
}

output "master_username" {
  value = "${aws_rds_cluster.spoke.master_username}"
}
