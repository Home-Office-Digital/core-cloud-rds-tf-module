mock_provider "aws" {}

variables {
  project_name = "demo"
  environment  = "dev"
  vpc_id       = "vpc-00000000000000000"
  subnet_ids   = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb"]

  tags = {
    cost-centre      = "CC1001"
    account-code     = "AC2002"
    portfolio-id     = "PF3003"
    project-id       = "PR4004"
    service-id       = "SV5005"
    environment-type = "nonprod"
    owner-business   = "platform"
    budget-holder    = "finops"
    source-repo      = "Home-Office-Digital/core-cloud-rds-tf-module"
    hosting-platform = "test-platform"
  }

  instances = {
    app = {
      allowed_cidr_blocks          = ["10.0.0.0/8"]
      copy_tags_to_snapshot        = true
      auto_minor_version_upgrade   = true
      availability_zone            = null
      allocated_storage            = 20
      backup_retention_period      = 7
      backup_window                = "22:00-03:00"
      ca_cert_identifier           = "rds-ca-rsa2048-g1"
      database_name                = "appdb"
      database_user                = "root"
      deletion_protection          = true
      engine                       = "postgres"
      engine_version               = "15.4"
      environment                  = "dev"
      final_snapshot_identifier    = null
      instance_class               = "db.t3.micro"
      iops                         = null
      kms_key_id                   = null
      maintenance_window           = "sun:06:00-sun:07:00"
      manage_master_user_password  = true
      multi_az                     = false
      name                         = "app-rds"
      performance_insights_enabled = true
      project_name                 = "demo"
      skip_final_snapshot          = true
      storage_type                 = "gp3"
      storage_encrypted            = true
      username                     = "root"
      dns                          = null
    }
  }
}

run "validate_existing_parameter_group_name" {
  command = plan

  variables {
    instances = {
      app = merge(var.instances.app, {
        parameter_group_name = "existing-parameter-group"
      })
    }
  }

  assert {
    condition     = aws_db_instance.this["app"].parameter_group_name == "existing-parameter-group"
    error_message = "Instance should attach an existing per-instance parameter group name"
  }
}

run "validate_existing_option_group_name" {
  command = plan

  variables {
    instances = {
      app = merge(var.instances.app, {
        engine            = "mysql"
        engine_version    = "8.0"
        option_group_name = "existing-option-group"
      })
    }
  }

  assert {
    condition     = aws_db_instance.this["app"].option_group_name == "existing-option-group"
    error_message = "Instance should attach an existing per-instance option group name"
  }
}

run "validate_group_configs_omit_to_null" {
  command = plan

  assert {
    condition     = local.parameter_group_name_by_instance["app"] == null
    error_message = "Instance should resolve parameter group name to null when no per-instance value is provided"
  }

  assert {
    condition     = local.option_group_name_by_instance["app"] == null
    error_message = "Instance should resolve option group name to null when no per-instance value is provided"
  }
}

run "validate_create_parameter_group" {
  command = plan

  variables {
    instances = {
      app = merge(var.instances.app, {
        create_parameter_group      = true
        parameter_group_name        = "app-parameter-group"
        parameter_group_family      = "postgres15"
        parameter_group_parameters = [
          {
            name  = "rds.force_ssl"
            value = "1"
          }
        ]
      })
    }
  }

  assert {
    condition     = length(aws_db_parameter_group.this) == 1
    error_message = "Expected one created DB parameter group"
  }

  assert {
    condition     = aws_db_parameter_group.this["app"].family == "postgres15"
    error_message = "Created parameter group should use the provided family"
  }

  assert {
    condition     = length(aws_db_parameter_group.this["app"].parameter) == 1
    error_message = "Created parameter group should include the provided parameter entry"
  }

  assert {
    condition     = contains([for parameter in aws_db_parameter_group.this["app"].parameter : parameter.name], "rds.force_ssl")
    error_message = "Created parameter group should map parameter_group_parameters.name into the parameter block"
  }

  assert {
    condition     = aws_db_instance.this["app"].parameter_group_name == "app-parameter-group"
    error_message = "Instance should attach the created parameter group"
  }
}

run "validate_create_option_group" {
  command = plan

  variables {
    instances = {
      app = merge(var.instances.app, {
        engine                             = "mysql"
        engine_version                     = "8.0"
        create_option_group              = true
        option_group_name                 = "app-option-group"
        option_group_major_engine_version = "8.0"
        option_group_options = [
          {
            option_name = "MARIADB_AUDIT_PLUGIN"
            option_settings = [
              {
                name  = "SERVER_AUDIT_EVENTS"
                value = "CONNECT"
              }
            ]
          }
        ]
      })
    }
  }

  assert {
    condition     = length(aws_db_option_group.this) == 1
    error_message = "Expected one created DB option group"
  }

  assert {
    condition     = aws_db_option_group.this["app"].major_engine_version == "8.0"
    error_message = "Created option group should use the provided major engine version"
  }

  assert {
    condition     = length(aws_db_option_group.this["app"].option) == 1
    error_message = "Created option group should include the provided option entry"
  }

  assert {
    condition     = contains([for option in aws_db_option_group.this["app"].option : option.option_name], "MARIADB_AUDIT_PLUGIN")
    error_message = "Created option group should map option_group_options.option_name into the option block"
  }

  assert {
    condition     = aws_db_instance.this["app"].option_group_name == "app-option-group"
    error_message = "Instance should attach the created option group"
  }
}

run "validate_shared_existing_parameter_group_across_instances" {
  command = plan

  variables {
    instances = {
      app = merge(var.instances.app, {
        parameter_group_name = "shared-existing-parameter-group"
      })
      reporting = merge(var.instances.app, {
        name                 = "reporting-rds"
        database_name        = "reporting"
        parameter_group_name = "shared-existing-parameter-group"
      })
    }
  }

  assert {
    condition     = length(aws_db_parameter_group.this) == 0
    error_message = "Expected no module-created parameter group when using shared existing group names"
  }

  assert {
    condition = alltrue([
      aws_db_instance.this["app"].parameter_group_name == "shared-existing-parameter-group",
      aws_db_instance.this["reporting"].parameter_group_name == "shared-existing-parameter-group"
    ])
    error_message = "Instances should be able to share the same existing parameter group"
  }
}

run "validate_shared_existing_option_group_across_instances" {
  command = plan

  variables {
    instances = {
      app = merge(var.instances.app, {
        engine            = "mysql"
        engine_version    = "8.0"
        option_group_name = "shared-existing-option-group"
      })
      reporting = merge(var.instances.app, {
        name              = "reporting-rds"
        engine            = "mysql"
        engine_version    = "8.0"
        option_group_name = "shared-existing-option-group"
      })
    }
  }

  assert {
    condition     = length(aws_db_option_group.this) == 0
    error_message = "Expected no module-created option group when using shared existing group names"
  }

  assert {
    condition = alltrue([
      aws_db_instance.this["app"].option_group_name == "shared-existing-option-group",
      aws_db_instance.this["reporting"].option_group_name == "shared-existing-option-group"
    ])
    error_message = "Instances should be able to share the same existing option group"
  }
}
