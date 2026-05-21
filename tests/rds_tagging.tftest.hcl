// Mock providers to avoid real AWS calls during tests.
mock_provider "aws" {}

  variables {
    project_name = "demo"
    environment  = "dev"
    vpc_id       = "vpc-00000000000000000"
    subnet_ids   = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb"]

    // Required organization tags
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

    // Create a single RDS instance with module-managed security group
    instances = {
      tagged-db = {
        allowed_cidr_blocks          = ["10.0.0.0/8"]
        copy_tags_to_snapshot        = true
        auto_minor_version_upgrade   = true
        availability_zone            = null
        allocated_storage            = 100
        backup_retention_period      = 7
        backup_window                = "03:00-04:00"
        ca_cert_identifier           = "rds-ca-rsa2048-g1"
        database_name                = "taggeddb"
        database_user                = "admin"
        deletion_protection          = false
        engine                       = "postgres"
        engine_version               = "15.4"
        environment                  = "dev"
        final_snapshot_identifier    = null
        instance_class               = "db.t3.medium"
        iops                         = null
        kms_key_id                   = null
        maintenance_window           = "Mon:04:00-Mon:05:00"
        manage_master_user_password  = true
        multi_az                     = false
        name                         = "test-tagged-db"
        performance_insights_enabled = true
        project_name                 = "demo"
        skip_final_snapshot          = true
        storage_type                 = "gp3"
        storage_encrypted            = true
        username                     = "root"
      }
    }
  }

run "validate_required_tags_on_rds" {
  command = plan

  assert {
    condition     = contains(keys(aws_db_instance.this["tagged-db"].tags), "cost-centre")
    error_message = "cost-centre tag must be present on RDS instance"
  }

  assert {
    condition     = contains(keys(aws_db_instance.this["tagged-db"].tags), "account-code")
    error_message = "account-code tag must be present on RDS instance"
  }

  assert {
    condition     = contains(keys(aws_db_instance.this["tagged-db"].tags), "portfolio-id")
    error_message = "portfolio-id tag must be present on RDS instance"
  }

  assert {
    condition     = contains(keys(aws_db_instance.this["tagged-db"].tags), "project-id")
    error_message = "project-id tag must be present on RDS instance"
  }

  assert {
    condition     = contains(keys(aws_db_instance.this["tagged-db"].tags), "service-id")
    error_message = "service-id tag must be present on RDS instance"
  }

  assert {
    condition     = contains(keys(aws_db_instance.this["tagged-db"].tags), "environment-type")
    error_message = "environment-type tag must be present on RDS instance"
  }

  assert {
    condition     = contains(keys(aws_db_instance.this["tagged-db"].tags), "owner-business")
    error_message = "owner-business tag must be present on RDS instance"
  }

  assert {
    condition     = contains(keys(aws_db_instance.this["tagged-db"].tags), "budget-holder")
    error_message = "budget-holder tag must be present on RDS instance"
  }

  assert {
    condition     = contains(keys(aws_db_instance.this["tagged-db"].tags), "source-repo")
    error_message = "source-repo tag must be present on RDS instance"
  }

  assert {
    condition     = contains(keys(aws_db_instance.this["tagged-db"].tags), "hosting-platform")
    error_message = "hosting-platform tag must be present on RDS instance"
  }
}

run "validate_security_group_tags" {
  command = plan

  variables {
    security_group_ids = null
  }

  assert {
    condition     = contains(keys(aws_security_group.this["tagged-db"].tags), "Name")
    error_message = "Name tag must be present on security group"
  }
}

run "validate_db_subnet_group_tags" {
  command = plan

  variables {
    db_subnet_group_name = null
  }

  assert {
    condition     = contains(keys(aws_db_subnet_group.this[0].tags), "Name")
    error_message = "Name tag must be present on DB subnet group"
  }
}


run "validate_environment_tag_values" {
  command = plan

  variables {
    environment = "test"
  }

  # Environment should be one of the standard values
  assert {
    condition     = contains(["sandbox", "test", "dev", "prelive", "live"], var.environment)
    error_message = "Environment should be one of: sandbox, test, dev, prelive, live"
  }
}

run "validate_multiple_instances_tagged" {
  command = plan

  variables {
    instances = {
      db1 = {
        allowed_cidr_blocks          = ["10.0.0.0/8"]
        copy_tags_to_snapshot        = true
        auto_minor_version_upgrade   = true
        availability_zone            = null
        allocated_storage            = 50
        backup_retention_period      = 7
        backup_window                = "03:00-04:00"
        ca_cert_identifier           = "rds-ca-rsa2048-g1"
        database_name                = "db1"
        database_user                = "admin"
        deletion_protection          = false
        engine                       = "postgres"
        engine_version               = "15.4"
        environment                  = "dev"
        final_snapshot_identifier    = null
        instance_class               = "db.t3.small"
        iops                         = null
        kms_key_id                   = null
        maintenance_window           = "Mon:04:00-Mon:05:00"
        manage_master_user_password  = true
        multi_az                     = false
        name                         = "test-db1"
        performance_insights_enabled = true
        project_name                 = "demo"
        skip_final_snapshot          = true
        storage_type                 = "gp3"
        storage_encrypted            = true
        username                     = "root"
      }
      db2 = {
        allowed_cidr_blocks          = ["10.0.0.0/8"]
        copy_tags_to_snapshot        = true
        auto_minor_version_upgrade   = true
        availability_zone            = null
        allocated_storage            = 50
        backup_retention_period      = 7
        backup_window                = "03:00-04:00"
        ca_cert_identifier           = "rds-ca-rsa2048-g1"
        database_name                = "db2"
        database_user                = "admin"
        deletion_protection          = false
        engine                       = "mysql"
        engine_version               = "8.0.35"
        environment                  = "dev"
        final_snapshot_identifier    = null
        instance_class               = "db.t3.small"
        iops                         = null
        kms_key_id                   = null
        maintenance_window           = "Mon:04:00-Mon:05:00"
        manage_master_user_password  = true
        multi_az                     = false
        name                         = "test-db2"
        performance_insights_enabled = true
        project_name                 = "demo"
        skip_final_snapshot          = true
        storage_type                 = "gp3"
        storage_encrypted            = true
        username                     = "root"
      }
    }
  }

  # Verify all instances are tagged
  assert {
    condition = alltrue([
      contains(keys(aws_db_instance.this["db1"].tags), "Name"),
      contains(keys(aws_db_instance.this["db2"].tags), "Name")
    ])
    error_message = "All RDS instances must have Name tag"
  }
}
