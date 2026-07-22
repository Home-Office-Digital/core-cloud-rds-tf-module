locals {
  dns_zone_normalized = var.dns_zone == null ? "" : trimspace(var.dns_zone)

  engine_ports = {
    postgres       = 5432
    mysql          = 3306
    mariadb        = 3306
    oracle-se2     = 1521
    oracle-ee      = 1521
    oracle-se2-cdb = 1521
    oracle-ee-cdb  = 1521
    sqlserver-ex   = 1433
    sqlserver-web  = 1433
    sqlserver-se   = 1433
    sqlserver-ee   = 1433
  }

  dns_record_names = [
    for _, instance in var.instances : lower(trimspace(instance.dns.name))
    if try(trimspace(instance.dns.name), "") != ""
  ]

  # Per-instance parameter group definitions for module-managed creation.
  parameter_groups_to_create_by_instance = {
    for key, instance in var.instances : key => {
      name        = try(trimspace(instance.parameter_group_name), "") != "" ? trimspace(instance.parameter_group_name) : "${instance.name}-parameter-group"
      description = try(trimspace(instance.parameter_group_description), "") != "" ? trimspace(instance.parameter_group_description) : "DB parameter group for ${instance.name}"
      family      = try(trimspace(instance.parameter_group_family), "") != "" ? trimspace(instance.parameter_group_family) : null
      parameters  = try(instance.parameter_group_parameters, [])
    }
    if try(instance.create_parameter_group, false)
  }

  # Final parameter group name each DB instance will attach to.
  parameter_group_name_by_instance = {
    for key, instance in var.instances : key => try(instance.create_parameter_group, false) ? aws_db_parameter_group.this[key].name : (
      try(trimspace(instance.parameter_group_name), "") != "" ? trimspace(instance.parameter_group_name) : null
    )
  }

  # Per-instance option group definitions for module-managed creation.
  option_groups_to_create_by_instance = {
    for key, instance in var.instances : key => {
      name                 = try(trimspace(instance.option_group_name), "") != "" ? trimspace(instance.option_group_name) : "${instance.name}-option-group"
      description          = try(trimspace(instance.option_group_description), "") != "" ? trimspace(instance.option_group_description) : "Option group for ${instance.name}"
      engine               = lower(instance.engine)
      major_engine_version = try(trimspace(instance.option_group_major_engine_version), "") != "" ? trimspace(instance.option_group_major_engine_version) : null
      options              = try(instance.option_group_options, [])
    }
    if try(instance.create_option_group, false)
  }

  # Final option group name each DB instance will attach to.
  option_group_name_by_instance = {
    for key, instance in var.instances : key => try(instance.create_option_group, false) ? aws_db_option_group.this[key].name : (
      try(trimspace(instance.option_group_name), "") != "" ? trimspace(instance.option_group_name) : null
    )
  }

  dns_record_names_unique = length(local.dns_record_names) == length(distinct(local.dns_record_names))
}
