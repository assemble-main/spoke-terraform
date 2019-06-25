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

# Create Aurora Postgres cluster
# Source: https://www.terraform.io/docs/providers/aws/r/rds_cluster.html
resource "aws_rds_cluster" "spoke" {
  cluster_identifier     = "${var.aws_client_tag}-spokedb"
  engine                 = "aurora-postgresql"
  engine_mode            = "${var.engine_mode}"
  db_subnet_group_name   = "${aws_db_subnet_group.postgres.name}"
  vpc_security_group_ids = ["${aws_security_group.postgres.id}"]
  copy_tags_to_snapshot  = "${var.copy_tags_to_snapshot}"
  storage_encrypted      = "${var.storage_encrypted}"

  # TODO - Unsure of what to set these to for PostgreSQL Serverless
  engine_version                  = "${var.engine_mode == "provisioned" ? var.engine_version : null}"
  db_cluster_parameter_group_name = "${var.db_cluster_parameter_group_name}"

  database_name   = "${var.rds_dbname}"
  master_username = "${var.rds_username}"
  master_password = "${var.rds_password}"

  # Deletion Behavior

  deletion_protection       = "${var.deletion_protection}"
  skip_final_snapshot       = "${var.skip_final_snapshot}"
  final_snapshot_identifier = "${var.aws_client_tag}-spokedb-final-snapshot"

  # Maintenance

  # enabled_cloudwatch_logs_exports = ["slowquery"]    # Not supported by Aurora Serverless at the moment
  backup_retention_period      = "${var.backup_retention_period}"
  preferred_backup_window      = "${var.preferred_backup_window}"
  preferred_maintenance_window = "${var.preferred_maintenance_window}"

  # Scaling configuration (serverless mode only)

  # Hack-ey way to make scaling_configuration block optional
  dynamic "scaling_configuration" {
    for_each = "${var.engine_mode == "serverless" ? ["create-the-block"] : []}"

    content {
      auto_pause   = false
      min_capacity = "${var.serverless_min_capacity}"
      max_capacity = "${var.serverless_max_capacity}"
    }
  }

  tags = {
    Name               = "${var.client_name_friendly} Spoke Postgres"
    "user:client"      = "${var.aws_client_tag}"
    "user:stack"       = "${var.aws_stack_tag}"
    "user:application" = "spoke"
  }
}

# Create Aurora Postgres cluster instances
# Source: https://www.terraform.io/docs/providers/aws/r/rds_cluster_instance.html
resource "aws_rds_cluster_instance" "spoke_cluster_instances" {
  count                   = "${var.engine_mode == "provisioned" ? var.aurora_instance_count : 0}"
  identifier              = "${var.aws_client_tag}-spokedb-${count.index}"
  cluster_identifier      = "${aws_rds_cluster.spoke.id}"
  engine                  = "aurora-postgresql"
  engine_version          = "${var.engine_mode == "provisioned" ? var.engine_version : null}"
  db_parameter_group_name = "${var.db_parameter_group_name}"
  instance_class          = "${var.aurora_instance_class}"

  publicly_accessible  = "${var.aurora_publicly_accessible}"
  db_subnet_group_name = "${aws_db_subnet_group.postgres.name}"
}
