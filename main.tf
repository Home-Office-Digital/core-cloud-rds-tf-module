data "aws_db_subnet_group" "existing" {
  count = var.db_subnet_group_name != null ? 1 : 0
  name  = var.db_subnet_group_name
}

data "aws_route53_zone" "selected" {
  count        = local.dns_zone_normalized != "" ? 1 : 0
  name         = "${trimsuffix(local.dns_zone_normalized, ".")}."
  private_zone = true
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

resource "aws_db_parameter_group" "this" {
  for_each = local.parameter_groups_to_create_by_instance

  name        = each.value.name
  family      = each.value.family
  description = each.value.description

  dynamic "parameter" {
    for_each = each.value.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  lifecycle {
    create_before_destroy = true

    precondition {
      condition     = each.value.family != null
      error_message = "parameter_group_family must be set when create_parameter_group is true."
    }

    precondition {
      condition     = length([for _, config in local.parameter_groups_to_create_by_instance : config.name]) == length(distinct([for _, config in local.parameter_groups_to_create_by_instance : config.name]))
      error_message = "Module-created parameter groups cannot be shared across instances."
    }
  }

  tags = merge(var.tags, {
    Name = each.value.name
  })
}

resource "aws_db_option_group" "this" {
  for_each = local.option_groups_to_create_by_instance

  name                     = each.value.name
  option_group_description = each.value.description
  engine_name              = each.value.engine
  major_engine_version     = each.value.major_engine_version

  dynamic "option" {
    for_each = each.value.options
    content {
      option_name                    = option.value.option_name
      port                           = option.value.port
      version                        = option.value.version
      db_security_group_memberships  = option.value.db_security_group_memberships
      vpc_security_group_memberships = option.value.vpc_security_group_memberships

      dynamic "option_settings" {
        for_each = option.value.option_settings
        content {
          name  = option_settings.value.name
          value = option_settings.value.value
        }
      }
    }
  }

  lifecycle {
    precondition {
      condition     = each.value.major_engine_version != null
      error_message = "option_group_major_engine_version must be set when create_option_group is true."
    }

    precondition {
      condition     = length([for _, config in local.option_groups_to_create_by_instance : config.name]) == length(distinct([for _, config in local.option_groups_to_create_by_instance : config.name]))
      error_message = "Module-created option groups cannot be shared across instances."
    }
  }

  tags = merge(var.tags, {
    Name = each.value.name
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
  manage_master_user_password     = var.manage_master_user_password
  max_allocated_storage           = var.max_allocated_storage
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.monitoring_role_arn
  multi_az                        = var.multi_az
  option_group_name               = local.option_group_name_by_instance[each.key]
  parameter_group_name            = local.parameter_group_name_by_instance[each.key]
  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_kms_key_id
  publicly_accessible             = var.publicly_accessible
  snapshot_identifier             = var.snapshot_identifier
  storage_type                    = var.storage_type
  storage_encrypted               = var.storage_encrypted
  skip_final_snapshot             = var.skip_final_snapshot
  username                        = lookup(each.value, "snapshot_identifier", null) == null ? var.database_user : null
  vpc_security_group_ids          = var.security_group_ids != null ? concat([var.security_group_ids[each.key]], var.vpc_security_group_ids) : [aws_security_group.this[each.key].id]

  tags = merge(var.tags, {
    Name = each.value.name
  })

  timeouts {
    create = "90m"
    update = "90m"
    delete = "90m"
  }

}

resource "aws_route53_record" "this" {
  for_each = local.dns_zone_normalized != "" ? {
    for key, instance in var.instances : key => instance
    if try(trimspace(instance.dns.name), "") != ""
  } : {}

  zone_id = data.aws_route53_zone.selected[0].id
  name    = trimspace(each.value.dns.name)
  type    = coalesce(try(each.value.dns.type, null), var.dns_type)
  ttl     = coalesce(try(each.value.dns.ttl, null), var.dns_ttl)
  records = [aws_db_instance.this[each.key].address]

  lifecycle {
    precondition {
      condition     = local.dns_record_names_unique
      error_message = "Duplicate DNS names detected across instances[*].dns.name. DNS record names must be unique per hosted zone."
    }
  }
}
