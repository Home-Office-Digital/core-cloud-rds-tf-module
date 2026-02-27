// Mock providers to avoid real AWS/random calls during tests.
mock_provider "aws" {}
mock_provider "random" {}

  variables {
    project_name = "demo"
    environment  = "dev"
    vpc_id       = "vpc-00000000000000000"
    subnet_ids   = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb"]
    region       = "eu-west-2"
    source-repo  = "github.com/UKHomeOffice/core-cloud-rds-tf-module"

    instances = {
      secure-db = {
        allowed_cidr_blocks             = ["10.0.0.0/8"]
        copy_tags_to_snapshot           = true
        auto_minor_version_upgrade      = true
        availability_zone               = null
        allocated_storage               = 100
        backup_retention_period         = 14
        backup_window                   = "03:00-04:00"
        ca_cert_identifier              = "rds-ca-rsa2048-g1"
        database_name                   = "securedb"
        database_user                   = "admin"
        deletion_protection             = false
        engine                          = "postgres"
        engine_version                  = "15.4"
        environment                     = "dev"
        final_snapshot_identifier       = null
        instance_class                  = "db.t3.micro"
        iops                            = null
        kms_key_id                      = null
        maintenance_window              = "Mon:04:00-Mon:05:00"
        manage_master_user_password     = true
        multi_az                        = false
        name                            = "test-secure-db"
        performance_insights_enabled    = true
        project_name                    = "demo"
        skip_final_snapshot             = true
        storage_type                    = "gp3"
        storage_encrypted               = true
        username                        = "admin"
        enabled_cloudwatch_logs_exports = ["postgresql"]
      }
    }

  tags = {}
}

run "validate_storage_encryption" {
  command = plan

  assert {
    condition     = aws_db_instance.this["secure-db"].storage_encrypted == true
    error_message = "RDS storage must be encrypted at rest"
  }
}

run "validate_kms_encryption" {
  command = plan

  variables {
    kms_key_arn = "arn:aws:kms:eu-west-2:123456789012:key/12345678-1234-1234-1234-123456789012"
  }

  assert {
    condition     = aws_db_instance.this["secure-db"].kms_key_id == "arn:aws:kms:eu-west-2:123456789012:key/12345678-1234-1234-1234-123456789012"
    error_message = "KMS key ARN must be used when provided"
  }
}

run "validate_backup_retention" {
  command = plan

  assert {
    condition     = aws_db_instance.this["secure-db"].backup_retention_period >= 7
    error_message = "Backup retention period must be at least 7 days"
  }

  assert {
    condition     = aws_db_instance.this["secure-db"].backup_window == "03:00-04:00"
    error_message = "Backup window must be defined"
  }
}

run "validate_final_snapshot_for_production" {
  command = plan

  variables {
    environment = "live"
    instances = {
      prod-db = {
        allowed_cidr_blocks             = ["10.0.0.0/8"]
        copy_tags_to_snapshot           = true
        auto_minor_version_upgrade      = true
        availability_zone               = null
        allocated_storage               = 500
        backup_retention_period         = 30
        backup_window                   = "03:00-04:00"
        ca_cert_identifier              = "rds-ca-rsa2048-g1"
        database_name                   = "production"
        database_user                   = "admin"
        deletion_protection             = false
        engine                          = "postgres"
        engine_version                  = "15.4"
        environment                     = "dev"
        final_snapshot_identifier       = null
        instance_class                  = "db.r6g.xlarge"
        iops                            = null
        kms_key_id                      = null
        maintenance_window              = "Mon:04:00-Mon:05:00"
        manage_master_user_password     = true
        multi_az                        = true
        name                            = "live-prod-db"
        performance_insights_enabled    = true
        project_name                    = "demo"
        skip_final_snapshot             = false
        final_snapshot_identifier       = "live-prod-db-final-snapshot"
        storage_type                    = "gp3"
        storage_encrypted               = true
        username                        = "admin"
        enabled_cloudwatch_logs_exports = ["postgresql"]
      }
    }
  }

  assert {
    condition     = aws_db_instance.this["prod-db"].skip_final_snapshot == false
    error_message = "Final snapshot must not be skipped for production databases"
  }

  assert {
    condition     = aws_db_instance.this["prod-db"].final_snapshot_identifier == "live-prod-db-final-snapshot"
    error_message = "Final snapshot identifier must be defined when skip_final_snapshot is false"
  }
}

run "validate_cloudwatch_logs_exports" {
  command = plan

  assert {
    condition     = contains(aws_db_instance.this["secure-db"].enabled_cloudwatch_logs_exports, "postgresql")
    error_message = "CloudWatch logs exports should include postgresql logs"
  }
}

run "validate_deletion_protection_for_live" {
  command = plan

  variables {
    environment = "live"
    instances = {
      protected-db = {
        allowed_cidr_blocks          = ["10.0.0.0/8"]
        copy_tags_to_snapshot        = true
        auto_minor_version_upgrade   = true
        availability_zone            = null
        allocated_storage            = 200
        backup_retention_period      = 30
        backup_window                = "03:00-04:00"
        ca_cert_identifier           = "rds-ca-rsa2048-g1"
        database_name                = "protected"
        database_user                = "admin"
        deletion_protection          = true
        engine                       = "postgres"
        engine_version               = "15.4"
        environment                  = "dev"
        final_snapshot_identifier    = null
        instance_class               = "db.r6g.large"
        iops                         = null
        kms_key_id                   = null
        maintenance_window           = "Mon:04:00-Mon:05:00"
        manage_master_user_password  = true
        multi_az                     = false
        name                         = "live-protected-db"
        performance_insights_enabled = true
        project_name                 = "demo"
        skip_final_snapshot          = true
        storage_type                 = "gp3"
        storage_encrypted            = true
        username                     = "admin"
      }
    }
  }

  assert {
    condition     = aws_db_instance.this["protected-db"].deletion_protection == true
    error_message = "Deletion protection must be enabled for live environments"
  }
}

run "validate_security_group_creation" {
  command = plan

  variables {
    security_group_ids = null
  }

  assert {
    condition     = length(aws_security_group.this) == 1
    error_message = "Security group should be created when security_group_ids is null"
  }
}

run "validate_security_group_ingress_postgres" {
  command = plan

  variables {
    security_group_ids = null
  }

  # Check PostgreSQL port in ingress rules
  assert {
    condition = alltrue([
      for rule in aws_security_group.this["secure-db"].ingress :
      rule.from_port == 5432
    ])
    error_message = "PostgreSQL port 5432 must be configured in security group"
  }

  assert {
    condition = alltrue([
      for rule in aws_security_group.this["secure-db"].ingress :
      rule.to_port == 5432
    ])
    error_message = "PostgreSQL port 5432 must be configured in security group"
  }

  assert {
    condition = alltrue([
      for rule in aws_security_group.this["secure-db"].ingress :
      rule.protocol == "tcp"
    ])
    error_message = "Security group must use TCP protocol"
  }
}