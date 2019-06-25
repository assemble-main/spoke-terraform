# Create security group for Postgres RDS
# Source: https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "postgres" {
  name        = "${var.aws_client_tag}-postgres"
  description = "Allow all inbound Postgres traffic"
  vpc_id      = "${var.vpc_id}"

  tags = {
    Name               = "${var.client_name_friendly} Spoke Postgres"
    "user:client"      = "${var.aws_client_tag}"
    "user:stack"       = "${var.aws_stack_tag}"
    "user:application" = "spoke"
  }
}

# Declare ingress/egress outside of main Security Group Definition so we can use individual rule resources elsewhere

resource "aws_security_group_rule" "postgres_self_ingress" {
  description       = "Postgres access from self."
  security_group_id = "${aws_security_group.postgres.id}"

  type      = "ingress"
  from_port = 5432
  to_port   = 5432
  protocol  = "tcp"
  self      = true
}

resource "aws_security_group_rule" "postgres_self_egress" {
  security_group_id = "${aws_security_group.postgres.id}"

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}


# Create RDS Subnet Group
# Source: https://www.terraform.io/docs/providers/aws/r/db_subnet_group.html
resource "aws_db_subnet_group" "postgres" {
  name       = "${var.aws_client_tag}-postgres"
  subnet_ids = var.subnet_ids

  tags = {
    Name               = "${var.client_name_friendly} Spoke Postgres"
    "user:client"      = "${var.aws_client_tag}"
    "user:stack"       = "${var.aws_stack_tag}"
    "user:application" = "spoke"
  }
}

# Create Serverless Postgres cluster
# Source: https://www.terraform.io/docs/providers/aws/r/rds_cluster.html
resource "aws_rds_cluster" "spoke" {
  cluster_identifier     = "${var.aws_client_tag}-spokedb"
  engine                 = "aurora-postgresql"
  engine_mode            = "${var.engine_mode}"
  db_subnet_group_name   = "${aws_db_subnet_group.postgres.name}"
  vpc_security_group_ids = ["${aws_security_group.postgres.id}"]
  copy_tags_to_snapshot  = true
  storage_encrypted      = true

  # TODO - Unsure of what to set these to for PostgreSQL Serverless
  # engine_version                  = ""
  # db_cluster_parameter_group_name = ""

  database_name   = "${var.rds_dbname}"
  master_username = "${var.rds_username}"
  master_password = "${var.rds_password}"

  # Deletion Behavior

  deletion_protection       = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.aws_client_tag}-spokedb-final-snapshot"

  # Maintenance

  # enabled_cloudwatch_logs_exports = ["slowquery"]    # Not supported by Aurora Serverless at the moment
  backup_retention_period      = 5
  preferred_backup_window      = "06:00-11:00"         # UTC
  preferred_maintenance_window = "sat:05:00-sat:05:30" # UTC

  # Scaling configuration (serverless mode only)

  scaling_configuration {
    auto_pause   = "${var.engine_mode == "serverless" ? false : null}"
    min_capacity = "${var.engine_mode == "serverless" ? var.serverless_min_capacity : null}"
    max_capacity = "${var.engine_mode == "serverless" ? var.serverless_max_capacity : null}"
  }

  tags = {
    Name               = "${var.client_name_friendly} Spoke Postgres"
    "user:client"      = "${var.aws_client_tag}"
    "user:stack"       = "${var.aws_stack_tag}"
    "user:application" = "spoke"
  }
}
