// Mock providers to avoid real AWS/random calls during tests.
mock_provider "aws" {}
mock_provider "random" {}

run "rds_with_new_security_group" {
  command = plan

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
    }

    // Create a single RDS instance with module-managed security group
    instances = {
      app = {
        allowed_cidr_blocks          = ["10.0.0.0/8"]
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

  assert {
    condition     = length(var.subnet_ids) == 2
    error_message = "Expected two subnets for the DB subnet group"
  }
}

run "rds_with_existing_security_group_and_subnet_group" {
  command = plan

  variables {
    project_name           = "demo"
    environment            = "dev"
    vpc_id                 = "vpc-00000000000000000"
    subnet_ids             = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb"]
    db_subnet_group_name   = "existing-db-subnet-group"
    vpc_security_group_ids = []
    security_group_ids     = { app = "sg-0123456789abcdef0" }

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
    }

    instances = {
      app = {
        // No allowed_cidr_blocks needed when using existing SG
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
        engine_version               = "15.6"
        environment                  = "dev"
        final_snapshot_identifier    = null
        instance_class               = "db.t3.micro"
        iops                         = null
        kms_key_id                   = null
        maintenance_window           = "sun:06:00-sun:07:00"
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

  assert {
    condition     = contains(keys(var.security_group_ids), "app")
    error_message = "Expected 'app' key in security_group_ids map"
  }
}
