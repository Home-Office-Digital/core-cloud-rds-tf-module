## Core Cloud RDS Module

This RDS Module is written and maintained by the Core Cloud Platform team and includes the following checks and scans:
Terraform validate, Terraform fmt, TFLint, Checkov scan, Sonarqube scan, Semantic versioning - MAJOR.MINOR.PATCH.

## Usage

See the below example configuration:

```
terraform {
  source = "https://github.com/UKHomeOffice/core-cloud-rds-tf-module.git?ref={tag}"
}

inputs = {
  vpc_id               = "xxx"
  subnet_ids           = ["xxx"]
  project_name         = "test-project"
  environment          = "test"
  db_subnet_group_name = "test-group"

  # RDS Instances Configuration
  instances = {
    test = {
      allocated_storage           = 20
      auto_minor_version_upgrade  = true
      backup_retention_period     = 7
      backup_window               = "22:00-03:00"
      ca_cert_identifier           = "rds-ca-rsa2048-g1"
      database_name               = "test"
      database_user               = "test"
      deletion_protection         = true
      engine                      = "xxx"
      engine_version              = "xxx"
      environment                 = "test"
      instance_class              = "db.t4g.micro"
      maintenance_window          = "Mon:04:00-Mon:05:00"
      multi_az                    = true
      name                        = "test"
      performance_insights_enabled = true
      project_name                = "test-project"
      skip_final_snapshot         = false
      storage_type                = "gp3"
      storage_encrypted           = true
    }
  }

  # Tags for all resources
  tags = {
    cost-centre      = "xxx"
    account-code     = "xxx"
    portfolio-id     = "xxx"
    project-id       = "xxx"
    service-id       = "xxx"
    environment-type = "xxx"
    owner-business   = "xxx"
    budget-holder    = "xxx"
    source-repo      = "xxx"
  }
}

```
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.88.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.88.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.6 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_secretsmanager_secret.rds_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.rds_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [random_password.rds](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_db_subnet_group.existing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/db_subnet_group) | data source |
| [aws_security_group.existing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Indicates that minor engine upgrades will be applied automatically to the RDSÅ instance during the maintenance window. | `bool` | `true` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | Must be specified if multi\_az = false | `string` | `null` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | n/a | `number` | `7` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | When AWS can run snapshot, can't overlap with maintenance window | `string` | `"22:00-03:00"` | no |
| <a name="input_ca_cert_identifier"></a> [ca\_cert\_identifier](#input\_ca\_cert\_identifier) | Specifies the identifier of the CA certificate for the DB | `string` | `"rds-ca-rsa2048-g1"` | no |
| <a name="input_database_user"></a> [database\_user](#input\_database\_user) | The username for the RDS to be created | `string` | `"root"` | no |
| <a name="input_db_subnet_group_name"></a> [db\_subnet\_group\_name](#input\_db\_subnet\_group\_name) | The name of the DB subnet group to use. | `string` | `null` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Enables deletion protection for the RDS instance. When set to true, the instance cannot be deleted unless this setting is disabled. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, staging, prod) | `string` | n/a | yes |
| <a name="input_instances"></a> [instances](#input\_instances) | A map of RDS instance configurations. | <pre>map(object({<br/>    allowed_cidr_blocks             = optional(list(string), [])<br/>    auto_minor_version_upgrade      = bool<br/>    availability_zone               = optional(string, null)<br/>    allocated_storage               = number<br/>    backup_retention_period         = number<br/>    backup_window                   = string<br/>    ca_cert_identifier              = string<br/>    database_name                   = string<br/>    database_user                   = string<br/>    deletion_protection             = bool<br/>    enabled_cloudwatch_logs_exports = optional(list(string), [])<br/>    engine                          = string<br/>    engine_version                  = string<br/>    environment                     = string<br/>    final_snapshot_identifier       = optional(string, null)<br/>    instance_class                  = string<br/>    iops                            = optional(number, null)<br/>    kms_key_id                      = optional(string, null)<br/>    maintenance_window              = string<br/>    multi_az                        = optional(bool, false)<br/>    name                            = string<br/>    performance_insights_enabled    = optional(bool, false)<br/>    project_name                    = string<br/>    skip_final_snapshot             = bool<br/>    snapshot_identifier             = optional(string)<br/>    storage_type                    = string<br/>    storage_encrypted               = string<br/>    username                        = string<br/>  }))</pre> | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | Optional KMS key ARN to encrypt the RDS and Secrets Manager secrets | `string` | `null` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Determines whether RDS instance uses multi-az | `bool` | `false` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | n/a | yes |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | If true, the RDS will be publicly accessible | `bool` | `false` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | A map of existing security group IDs to use for the instances, keyed by the instance name. If not provided, new ones will be created. | `map(string)` | `null` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Determines whether a final DB snapshot is created before the DB instance is deleted | `bool` | `true` | no |
| <a name="input_snapshot_identifier"></a> [snapshot\_identifier](#input\_snapshot\_identifier) | Specifies whether or not to create this database from a snapshot. | `string` | `null` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Specifies whether the RDS instance storage is encrypted | `bool` | `true` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | One of 'standard' (magnetic), 'gp2' (general purpose SSD), 'gp3' (new generation of general purpose SSD), or 'io1' (provisioned IOPS SSD). | `string` | `"gp3"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnet IDs for the DB Subnet Group. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The following tags must be applied to all resources: cost-centre, account-code, portfolio-id, project-id, service-id, environment-type, owner-business, budget-holder and source-repo | <pre>object({<br/>    cost-centre      = string<br/>    account-code     = string<br/>    portfolio-id     = string<br/>    project-id       = string<br/>    service-id       = string<br/>    environment-type = string<br/>    owner-business   = string<br/>    budget-holder    = string<br/>    source-repo      = string<br/>  })</pre> | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where RDS instance will be created | `string` | n/a | yes |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | A list of additional VPC security group IDs. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoints"></a> [endpoints](#output\_endpoints) | A map of connection endpoints for all RDS instances |
| <a name="output_instance_ids"></a> [instance\_ids](#output\_instance\_ids) | A map of RDS instance IDs |
| <a name="output_rds_instance_ids"></a> [rds\_instance\_ids](#output\_rds\_instance\_ids) | A map of RDS instance IDs |
| <a name="output_rds_password_secrets"></a> [rds\_password\_secrets](#output\_rds\_password\_secrets) | A map of Secrets Manager ARNs for RDS passwords (only if AWS is NOT managing passwords) |
| <a name="output_security_group_ids"></a> [security\_group\_ids](#output\_security\_group\_ids) | n/a |
