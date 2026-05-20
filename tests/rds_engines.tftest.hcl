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
      source-repo      = "UKHomeOffice/core-cloud-rds-tf-module"
      hosting-platform = "test-platform"
    }

    // Create a single RDS instance with module-managed security group
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
        engine                       = "mysql"
        engine_version               = "8.0"
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
      }
    }
  }

run "validate_postgres_port" {
  command = plan

  variables {
    security_group_ids = null
    instances = {
      postgres-db = {
        allowed_cidr_blocks          = ["10.0.0.0/8"]
        copy_tags_to_snapshot        = true
        auto_minor_version_upgrade   = true
        availability_zone            = null
        allocated_storage            = 50
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
        name                         = "test-postgres-db"
        performance_insights_enabled = true
        project_name                 = "demo"
        skip_final_snapshot          = true
        storage_type                 = "gp3"
        storage_encrypted            = true
        username                     = "admin"
      }
    }
  }

  # Check that security group has PostgreSQL port configured
  assert {
    condition = alltrue([
      for rule in aws_security_group.this["postgres-db"].ingress :
      rule.from_port == 5432 && rule.to_port == 5432
    ])
    error_message = "PostgreSQL engine must use port 5432"
  }
  # Verify TCP protocol is used for PostgreSQL
  assert {
    condition = alltrue([
      for rule in aws_security_group.this["postgres-db"].ingress :
      rule.protocol == "tcp"
    ])
    error_message = "Security group must use TCP protocol"
  }

}

run "validate_mysql_port" {
  command = plan

  variables {
    security_group_ids = null
    instances = {
      mysql-db = {
        allowed_cidr_blocks          = ["10.0.0.0/8"]
        copy_tags_to_snapshot        = true
        auto_minor_version_upgrade   = true
        availability_zone            = null
        allocated_storage            = 50
        backup_retention_period      = 7
        backup_window                = "03:00-04:00"
        ca_cert_identifier           = "rds-ca-rsa2048-g1"
        database_name                = "mysql"
        database_user                = "admin"
        deletion_protection          = true
        engine                       = "mysql"
        engine_version               = "8.0.35"
        environment                  = "dev"
        final_snapshot_identifier    = null
        instance_class               = "db.t3.small"
        iops                         = null
        kms_key_id                   = null
        maintenance_window           = "sun:06:00-sun:07:00"
        manage_master_user_password  = true
        multi_az                     = false
        name                         = "test-mysql-db"
        performance_insights_enabled = true
        project_name                 = "demo"
        skip_final_snapshot          = true
        storage_type                 = "gp3"
        storage_encrypted            = true
        username                     = "admin"
        environment                 = "test"
        project_name                = "test"
      }
    }
  }

  # Check that security group has MySQL port configured
  assert {
    condition = alltrue([
      for rule in aws_security_group.this["mysql-db"].ingress :
      rule.from_port == 3306 && rule.to_port == 3306
    ])
    error_message = "MySQL engine must use port 3306"
  }

  # Verify TCP protocol is used for MySQL
  assert {
    condition = alltrue([
      for rule in aws_security_group.this["mysql-db"].ingress :
      rule.protocol == "tcp"
    ])
    error_message = "Security group must use TCP protocol"
  }

}

run "validate_mariadb_port" {
  command = plan

  variables {
    security_group_ids = null
    instances = {
      mariadb-db = {
        allowed_cidr_blocks          = ["10.0.0.0/8"]
        copy_tags_to_snapshot        = true
        auto_minor_version_upgrade   = true
        availability_zone            = null
        allocated_storage            = 50
        backup_retention_period      = 7
        backup_window                = "03:00-04:00"
        ca_cert_identifier           = "rds-ca-rsa2048-g1"
        database_name                = "mariadb"
        database_user                = "admin"
        deletion_protection          = true
        engine                       = "mariadb"
        engine_version               = "10.11.6"
        environment                  = "dev"
        final_snapshot_identifier    = null
        instance_class               = "db.t3.small"
        iops                         = null
        kms_key_id                   = null
        maintenance_window           = "sun:06:00-sun:07:00"
        manage_master_user_password  = true
        multi_az                     = false
        name                         = "test-mariadb-db"
        performance_insights_enabled = true
        project_name                 = "demo"
        skip_final_snapshot          = true
        storage_type                 = "gp3"
        storage_encrypted            = true
        username                     = "admin"
        environment                 = "test"
        project_name                = "test"
      }
    }
  }

  # Check that security group has MariaDB port configured
  assert {
    condition = alltrue([
      for rule in aws_security_group.this["mariadb-db"].ingress :
      rule.from_port == 3306 && rule.to_port == 3306
    ])
    error_message = "MariaDB engine must use port 3306"
  }
  # Verify TCP protocol is used for MariaDB
  assert {
    condition = alltrue([
      for rule in aws_security_group.this["mariadb-db"].ingress :
      rule.protocol == "tcp"
    ])
    error_message = "Security group must use TCP protocol"
  }
}
