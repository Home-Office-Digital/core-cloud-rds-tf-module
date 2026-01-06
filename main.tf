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
  for_each         = { for k, v in var.instances : k => v if !v.manage_master_user_password }
  length           = 16
  special          = true
  override_special = "!#$%^&*()-_=+[]{}|:;,.<>?"
}

resource "aws_secretsmanager_secret" "rds_password" {
  for_each    = random_password.rds
  name        = "${each.key}-rds-password"
  description = "RDS master password for ${each.key}"
}

resource "aws_secretsmanager_secret_version" "rds_password" {
  for_each      = random_password.rds
  secret_id     = aws_secretsmanager_secret.rds_password[each.key].id
  secret_string = each.value.result
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
resource "aws_db_instance" "managed_password" {
  for_each = { for k, v in var.instances : k => v if v.manage_master_user_password }

  allocated_storage           = lookup(each.value, "snapshot_identifier", null) == null ? each.value.allocated_storage : null
  auto_minor_version_upgrade  = each.value.auto_minor_version_upgrade
  backup_retention_period     = each.value.backup_retention_period
  backup_window               = each.value.backup_window
  db_name                     = lookup(each.value, "snapshot_identifier", null) == null ? each.value.database_name : null
  db_subnet_group_name        = var.db_subnet_group_name != null ? data.aws_db_subnet_group.existing[0].name : aws_db_subnet_group.this[0].name
  deletion_protection         = each.value.deletion_protection
  engine                      = lookup(each.value, "snapshot_identifier", null) == null ? each.value.engine : null
  engine_version              = lookup(each.value, "snapshot_identifier", null) == null ? each.value.engine_version : null
  final_snapshot_identifier   = lookup(each.value, "final_snapshot_identifier", null)
  identifier                  = each.value.name
  instance_class              = each.value.instance_class
  kms_key_id                  = var.kms_key_arn != null ? var.kms_key_arn : null
  maintenance_window          = each.value.maintenance_window
  manage_master_user_password = true
  multi_az                    = each.value.multi_az
  snapshot_identifier         = lookup(each.value, "snapshot_identifier", null)
  storage_type                = each.value.storage_type
  storage_encrypted           = each.value.storage_encrypted
  skip_final_snapshot         = each.value.skip_final_snapshot
  username                    = lookup(each.value, "snapshot_identifier", null) == null ? each.value.database_user : null
  vpc_security_group_ids = concat(
    [
      var.security_group_ids != null ?
      data.aws_security_group.existing[each.key].id :
      aws_security_group.this[each.key].id
    ],
    var.vpc_security_group_ids
  )

  lifecycle {
    precondition {
      condition     = var.instances.secret_name != null
      error_message = "The secret_name must be provided as a parameter if manage_master_user_password is true."
    }
  }

  tags = merge(var.tags, {
    Name = each.value.name
  })

  timeouts {
    create = "90m"
    update = "90m"
    delete = "90m"
  }
}

resource "aws_db_instance" "custom_password" {
  for_each = { for k, v in var.instances : k => v if !v.manage_master_user_password }

  allocated_storage          = lookup(each.value, "snapshot_identifier", null) == null ? each.value.allocated_storage : null
  auto_minor_version_upgrade = each.value.auto_minor_version_upgrade
  backup_retention_period    = each.value.backup_retention_period
  backup_window              = each.value.backup_window
  db_name                    = lookup(each.value, "snapshot_identifier", null) == null ? each.value.database_name : null
  db_subnet_group_name       = var.db_subnet_group_name != null ? data.aws_db_subnet_group.existing[0].name : aws_db_subnet_group.this[0].name
  deletion_protection        = each.value.deletion_protection
  engine                     = lookup(each.value, "snapshot_identifier", null) == null ? each.value.engine : null
  engine_version             = lookup(each.value, "snapshot_identifier", null) == null ? each.value.engine_version : null
  final_snapshot_identifier  = each.value.skip_final_snapshot ? null : "${each.key}-final-snapshot"
  identifier                 = each.value.name
  instance_class             = each.value.instance_class
  kms_key_id                 = var.kms_key_arn != null ? var.kms_key_arn : null
  maintenance_window         = each.value.maintenance_window
  password                   = aws_secretsmanager_secret_version.rds_password[each.key].secret_string
  multi_az                   = each.value.multi_az
  snapshot_identifier        = lookup(each.value, "snapshot_identifier", null)
  storage_type               = each.value.storage_type
  storage_encrypted          = each.value.storage_encrypted
  skip_final_snapshot        = each.value.skip_final_snapshot
  username                   = lookup(each.value, "snapshot_identifier", null) == null ? each.value.database_user : null
  vpc_security_group_ids = concat(
    [
      var.security_group_ids != null ?
      data.aws_security_group.existing[each.key].id :
      aws_security_group.this[each.key].id
    ],
    var.vpc_security_group_ids
  )

  lifecycle {
    precondition {
      condition     = var.instances.secret_name == null
      error_message = "The secret_name must not be provided as a parameter if manage_master_user_password is false."
    }
  }

  tags = merge(var.tags, {
    Name = each.value.name
  })

  timeouts {
    create = "90m"
    update = "90m"
    delete = "90m"
  }
}
