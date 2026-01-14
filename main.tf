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

data "aws_security_group" "existing" {
  for_each = var.security_group_ids != null ? var.security_group_ids : {}
  id       = each.value
}

resource "random_password" "rds" {
  count            = local.aws_managed_password ? 0 : 1
  length           = 16
  special          = true
  override_special = "!#$%^&*()-_=+[]{}|:;,.<>?"
}

resource "aws_secretsmanager_secret" "custom" {
  count       = local.aws_managed_password || local.aws_managed_password ? 1 : 0
  name        = local.secret_name
  description = "RDS master password for ${var.name}"
  kms_key_id  = var.kms_key_id

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "rds_password" {
  count     = local.aws_managed_password ? 0 : 1
  secret_id = aws_secretsmanager_secret.custom[0].id
  secret_string = jsonencode({
    username = var.username
    password = random_password.rds[0].result
  })
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
    cidr_blocks = each.value.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-${each.key}-rds-sg"
  })
}

# Main RDS Instance
resource "aws_db_instance" "this" {
  for_each = { for k, v in var.instances : k => v if v.manage_master_user_password }

  allocated_storage               = var.allocated_storage
  availability_zone               = var.multi_az ? null : var.availability_zone
  backup_retention_period         = var.backup_retention_period
  backup_window                   = var.backup_window
  ca_cert_identifier              = var.ca_cert_identifier
  db_name                         = var.database_name
  db_subnet_group_name            = var.db_subnet_group_name != null ? data.aws_db_subnet_group.existing[0].name : aws_db_subnet_group.this[0].name
  deletion_protection             = var.deletion_protection
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  engine                          = var.engine
  engine_version                  = var.engine_version
  final_snapshot_identifier       = var.final_snapshot_identifier
  identifier                      = var.name
  instance_class                  = var.instance_class
  iops                            = var.iops
  kms_key_id                      = var.kms_key_arn != null ? var.kms_key_arn : null
  maintenance_window              = var.maintenance_window

  manage_master_user_password = local.aws_managed_password

  password = local.aws_managed_password ? null : random_password.rds[0].result

  multi_az                     = var.multi_az
  performance_insights_enabled = var.performance_insights_enabled
  publicly_accessible          = false
  snapshot_identifier          = var.snapshot_identifier
  storage_type                 = var.storage_type
  storage_encrypted            = true
  skip_final_snapshot          = var.skip_final_snapshot
  username                     = var.username
  vpc_security_group_ids = concat(
    [
      var.security_group_ids != null ?
      data.aws_security_group.existing[each.key].id :
      aws_security_group.this[each.key].id
    ],
    var.vpc_security_group_ids
  )
  tags = var.tags

  timeouts {
    create = "90m"
    update = "90m"
    delete = "90m"
  }
}
