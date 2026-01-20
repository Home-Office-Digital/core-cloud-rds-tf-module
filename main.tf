data "aws_db_subnet_group" "existing" {
  count = var.db_subnet_group_name != null ? 1 : 0
  name  = var.db_subnet_group_name
}

resource "aws_db_subnet_group" "this" {
  count = var.db_subnet_group_name == null ? 1 : 0
  # You can create a more dynamic name if you wish
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  })
}

resource "random_password" "rds" {
  for_each         = var.instances
  length           = 16
  special          = true
  override_special = "!#$%^&*()-_=+[]{}|:;,.<>?"
}

resource "aws_secretsmanager_secret" "rds_password" {
  for_each    = var.instances
  name        = "${var.project_name}-${each.key}-rds-password"
  description = "RDS master password for ${each.key}"
  kms_key_id  = var.kms_key_arn != null ? var.kms_key_arn : null

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-${each.key}-rds-sg"
  })
}


resource "aws_secretsmanager_secret_version" "rds_password" {
  for_each      = var.instances
  secret_id     = aws_secretsmanager_secret.rds_password[each.key].id
  secret_string = random_password.rds[each.key].result
}

resource "aws_secretsmanager_secret_rotation" "rds_password_rotation" {
  for_each  = var.instances
  secret_id = aws_secretsmanager_secret.rds_password[each.key].id
  rotation_rules {
    automatically_after_days = 7
  }
}

resource "aws_security_group" "this" {
  for_each    = var.security_group_ids == null ? var.instances : {}
  name        = "${var.project_name}-${var.environment}-${each.key}-rds-sg"
  description = "Security group for ${each.key} RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    # Dynamically look up the port based on the instance's engine type
    from_port   = lookup(local.engine_ports, each.value.engine, 0)
    to_port     = lookup(local.engine_ports, each.value.engine, 0)
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "Security group ingress rule for ${each.key} RDS instance"
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "tcp"
    # Change this to your internal VPC CIDR or a specific monitoring IP. Egress should be restricted to internal VPC only
    cidr_blocks = var.allowed_cidr_blocks
    description = "Security group egress rule for ${each.key} RDS instance"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-${each.key}-rds-sg"
  })
}

# Main RDS Instance
resource "aws_db_instance" "this" {
  for_each = var.instances

  allocated_storage               = lookup(each.value, "snapshot_identifier", null) == null ? each.value.allocated_storage : null
  availability_zone               = var.availability_zone
  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  backup_retention_period         = var.backup_retention_period
  backup_window                   = var.backup_window
  ca_cert_identifier              = var.ca_cert_identifier
  copy_tags_to_snapshot           = var.copy_tags_to_snapshot
  db_name                         = lookup(each.value, "snapshot_identifier", null) == null ? each.value.database_name : null
  db_subnet_group_name            = var.db_subnet_group_name != null ? data.aws_db_subnet_group.existing[0].name : aws_db_subnet_group.this[0].name
  dedicated_log_volume            = var.dedicated_log_volume
  deletion_protection             = var.deletion_protection
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  engine                          = lookup(each.value, "snapshot_identifier", null) == null ? each.value.engine : null
  engine_version                  = lookup(each.value, "snapshot_identifier", null) == null ? each.value.engine_version : null
  final_snapshot_identifier       = lookup(each.value, "final_snapshot_identifier", null)
  identifier                      = each.value.name
  instance_class                  = each.value.instance_class
  iops                            = var.iops
  kms_key_id                      = var.kms_key_arn != null ? var.kms_key_arn : null
  maintenance_window              = each.value.maintenance_window
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.monitoring_role_arn
  multi_az                        = var.multi_az
  password                        = aws_secretsmanager_secret_version.rds_password[each.key].secret_string
  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_kms_key_id
  publicly_accessible             = var.publicly_accessible
  snapshot_identifier             = var.snapshot_identifier
  storage_type                    = var.storage_type
  storage_encrypted               = var.storage_encrypted
  skip_final_snapshot             = var.skip_final_snapshot
  username                        = lookup(each.value, "snapshot_identifier", null) == null ? var.database_user : null
  vpc_security_group_ids          = concat([aws_security_group.this[each.key].id], var.vpc_security_group_ids)

  tags = merge(var.tags, {
    Name = each.value.name
  })

  timeouts {
    create = "90m"
    update = "90m"
    delete = "90m"
  }
}
