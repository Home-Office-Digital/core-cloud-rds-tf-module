// Mock providers to avoid real AWS calls during tests.
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
    }
    reporting = {
      allowed_cidr_blocks          = ["10.0.0.0/8"]
      copy_tags_to_snapshot        = true
      auto_minor_version_upgrade   = true
      availability_zone            = null
      allocated_storage            = 20
      backup_retention_period      = 7
      backup_window                = "22:00-03:00"
      ca_cert_identifier           = "rds-ca-rsa2048-g1"
      database_name                = "reporting"
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
      name                         = "reporting-rds"
      performance_insights_enabled = true
      project_name                 = "demo"
      skip_final_snapshot          = true
      storage_type                 = "gp3"
      storage_encrypted            = true
      username                     = "root"
    }
  }
}

run "validate_no_dns_records_without_zone" {
  command = plan

  variables {
    dns_zone = null

    instances = merge(var.instances, {
      app = merge(var.instances.app, {
        dns = {
          name = "app-rds"
        }
      })
      reporting = merge(var.instances.reporting, {
        dns = {
          name = "reporting-rds"
        }
      })
    })
  }

  assert {
    condition     = length(aws_route53_record.this) == 0
    error_message = "No Route53 records should be created when dns_zone is not set"
  }
}

run "validate_dns_defaults" {
  command = plan

  variables {
    dns_zone = "example.service.gov.uk"

    instances = merge(var.instances, {
      app = merge(var.instances.app, {
        dns = {
          name = "app-rds"
        }
      })
      reporting = merge(var.instances.reporting, {
        dns = {
          name = "reporting-rds"
        }
      })
    })
  }

  assert {
    condition     = length(aws_route53_record.this) == 2
    error_message = "One Route53 record should be created per instance with non-empty dns.name when dns_zone is set"
  }

  assert {
    condition = alltrue([
      aws_route53_record.this["app"].type == "CNAME",
      aws_route53_record.this["reporting"].type == "CNAME"
    ])
    error_message = "Record type should always be CNAME"
  }

  assert {
    condition = alltrue([
      aws_route53_record.this["app"].ttl == 300,
      aws_route53_record.this["reporting"].ttl == 300
    ])
    error_message = "Record ttl should default to dns_ttl"
  }
}

run "validate_per_instance_dns_overrides" {
  command = plan

  variables {
    dns_zone = "example.service.gov.uk"

    instances = merge(var.instances, {
      app = merge(var.instances.app, {
        dns = {
          name = "app-db"
          ttl  = 60
        }
      })
      reporting = merge(var.instances.reporting, {
        dns = {
          name = "reporting-db"
          ttl  = 120
        }
      })
    })
  }

  assert {
    condition = alltrue([
      aws_route53_record.this["app"].name == "app-db",
      aws_route53_record.this["reporting"].name == "reporting-db"
    ])
    error_message = "Record names should use per-instance dns.name values"
  }

  assert {
    condition = alltrue([
      aws_route53_record.this["app"].ttl == 60,
      aws_route53_record.this["reporting"].ttl == 120
    ])
    error_message = "Per-instance dns.ttl should override default ttl"
  }
}

run "validate_per_instance_dns_name_presence_filter" {
  command = plan

  variables {
    dns_zone = "example.service.gov.uk"

    instances = merge(var.instances, {
      app = merge(var.instances.app, {
        dns = {
          name = "app-db"
        }
      })
      reporting = merge(var.instances.reporting, {
        dns = {
        }
      })
    })
  }

  assert {
    condition     = length(aws_route53_record.this) == 1
    error_message = "Only instances with non-empty dns.name should create Route53 records"
  }

  assert {
    condition = alltrue([
      contains(keys(aws_route53_record.this), "app"),
      !contains(keys(aws_route53_record.this), "reporting")
    ])
    error_message = "Instances without dns.name should be excluded from Route53 record creation"
  }
}
