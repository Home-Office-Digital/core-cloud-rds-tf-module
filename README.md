# Core Cloud RDS Module

This RDS Child Module is written and maintained by the Core Cloud Platform team and includes the following checks and scans:
Terraform validate, Terraform fmt, TFLint, Checkov scan, Sonarqube scan and Semantic versioning - MAJOR.MINOR.PATCH.

## Module Structure

<strong>---| .github</strong>  
&nbsp;&nbsp;&nbsp;&nbsp;<strong>---| [dependabot.yaml](https://github.com/Home-Office-Digital/core-cloud-rds-tf-module/blob/main/.github/dependabot.yaml)</strong> - Checks repository daily for any dependency updates and raises a PR into main for review.  \
&nbsp;&nbsp;&nbsp;&nbsp;<strong>---| workflows</strong> \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>---| [pull-request-sast.yaml](https://github.com/Home-Office-Digital/core-cloud-rds-tf-module/blob/main/.github/workflows/pull-request-sast.yaml)</strong> - Workflow containing terraform init, terraform validate, terraform fmt - referencing Core Cloud TFLint, Checkov scan and Sonarqube scan shared workflows. Runs on pull request and merge to main branch. \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>---| [pull-request-semver-label-check.yaml](https://github.com/Home-Office-Digital/core-cloud-rds-tf-module/blob/main/.github/workflows/pull-request-semver-label-check.yaml)</strong> - Verifies all PRs to main raised in the module must have an appropriate semver label: major/minor/patch. \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>---| [pull-request-semver-tag-merge.yaml](https://github.com/Home-Office-Digital/core-cloud-rds-tf-module/blob/main/.github/workflows/pull-request-semver-tag-merge.yaml)</strong> - Calculates the new semver value depending on the PR label and tags the repository with the correct tag. \
<strong>---| tests</strong> \
&nbsp;&nbsp;<strong>---| [rds-basic.tftest.hcl](https://github.com/Home-Office-Digital/core-cloud-rds-tf-module/blob/main/tests/rds-basic.tftest.hcl)</strong> \
<strong>---| [CHANGELOG.md](https://github.com/Home-Office-Digital/core-cloud-rds-tf-module/blob/main/CHANGELOG.md)</strong> - Contains all significant changes in relation to a semver tag made to this module. \
<strong>---| [CODEOWNERS](https://github.com/Home-Office-Digital/core-cloud-rds-tf-module/blob/main/CODEOWNERS)</strong> \
<strong>---| [CONTRIBUTING.md](https://github.com/Home-Office-Digital/core-cloud-rds-tf-module/blob/main/LICENSE.md)</strong>  \
<strong>---| [LICENSE.md](https://github.com/Home-Office-Digital/core-cloud-rds-tf-module/blob/main/LICENSE.md)</strong>  \
<strong>---| [README.md](https://github.com/Home-Office-Digital/core-cloud-rds-tf-module/blob/main/README.md)</strong>  \
<strong>---| [locals.tf](https://github.com/Home-Office-Digital/core-cloud-rds-tf-module/blob/main/locals.tf)</strong> - Contains RDS Engine respective ports so port is dynamically picked up here when engine is provided in configuration.  \
<strong>---| [main.tf](https://github.com/Home-Office-Digital/core-cloud-rds-tf-module/blob/main/main.tf)</strong> - Contains the main set of configuration for this module.  \
<strong>---| [outputs.tf](https://github.com/Home-Office-Digital/core-cloud-rds-tf-module/blob/main/outputs.tf)</strong> - Contain the output definitions for this module.  \
<strong>---| [variables.tf](https://github.com/Home-Office-Digital/core-cloud-rds-tf-module/blob/main/variables.tf)</strong> - Contains the declarations for module variables, all variables have a defined type and short description outlining their purpose.  \
<strong>---| [versions.tf](https://github.com/Home-Office-Digital/core-cloud-rds-tf-module/blob/main/versions.tf)</strong> - Contains the providers needed by the module.  

## Terraform Tests

All module tests are located in the test/ folder and uses Terraform test. These are written and maintained by the Core Cloud QA team.  \
The test files found in this folder validate the RDS module configuration.  \
Please refer to the [Official Hashicorp Terraform Test documentation](https://developer.hashicorp.com/terraform/language/tests).

## Usage 

This module will create the following:
- DB instance (MySQL, Postgres, SQL Server, Oracle)
- DB Subnet Group
- DB Security Group
- AWS Secrets Manager AWS Managed RDS Secret (7 Day automatic rotation enabled by default - Adjustment to rotation schedule or opt out via AWS Console). For guidance, this is [rotation disable documented here](https://docs.aws.amazon.com/secretsmanager/latest/userguide/cancel-automatic-rotation.html) and [rotation schedule adjustment documented here](https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotate-secrets_managed.html).

Recommended settings:

- Enable deletion protection
- Adhere to Core Cloud mandatory tags
- AWS Managed Secrets Manager RDS secrets should have automatic rotation enabled
- Enable enhanced monitoring and performance insights
- Enable copy tags to snapshots
- Automatic minor upgrades
- Enable Multi-AZ
- Enable encryption
- Enable automated backups & Sufficient backup retention period
- Disable public accessibility

See the below example configuration (We recommend one file per environment containing all RDS instances using this module):

```
terraform {
  source = "https://github.com/Home-Office-Digital/core-cloud-rds-tf-module.git?ref={tag}"
}

inputs = {
  allowed_cidr_blocks  = [x.x.x.x/x]
  db_subnet_group_name = "<project_name>-<environment>-subnet-group"
  environment          = "test"
  project_name         = "test-project"
  subnet_ids           = ["xxx"]
  vpc_id               = "xxx"

  # RDS Instances Configuration
  instances = {
    test = {
      allocated_storage               = 20
      auto_minor_version_upgrade      = true
      backup_retention_period         = 7
      backup_window                   = "22:00-03:00"
      ca_cert_identifier              = "rds-ca-rsa2048-g1"
      copy_tags_to_snapshot           = true
      database_name                   = "test"
      database_user                   = "test"
      deletion_protection             = true
      enabled_cloudwatch_logs_exports = ["postgresql"]
      engine                          = "postgres"
      engine_version                  = "xx"
      environment                     = "test"
      instance_class                  = "db.t4g.micro"
      maintenance_window              = "Mon:04:00-Mon:05:00"
      manage_master_user_password     = true
      multi_az                        = true
      name                            = "test"
      performance_insights_enabled    = true
      project_name                    = "test-project"
      skip_final_snapshot             = false
      storage_type                    = "gp3"
      storage_encrypted               = true
      username                        = "test"
    }
    test-2 = {
      allocated_storage               = 20
      auto_minor_version_upgrade      = true
      backup_retention_period         = 7
      backup_window                   = "22:00-03:00"
      ca_cert_identifier              = "rds-ca-rsa2048-g1"
      copy_tags_to_snapshot           = true
      database_name                   = "test"
      database_user                   = "test"
      deletion_protection             = true
      enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
      engine                          = "postgres"
      engine_version                  = "xx"
      environment                     = "test"
      instance_class                  = "db.t4g.micro"
      maintenance_window              = "Mon:04:00-Mon:05:00"
      manage_master_user_password     = true
      multi_az                        = true
      name                            = "test"
      performance_insights_enabled    = true
      project_name                    = "test-project"
      skip_final_snapshot             = false
      storage_type                    = "gp3"
      storage_encrypted               = true
      username                        = "test"
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
  }
}

```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.88.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.88.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_db_subnet_group.existing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/db_subnet_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | A list of allowed CIDRs for the DB Subnet Group. | `list(string)` | `[]` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Indicates that minor engine upgrades will be applied automatically to the RDSÅ instance during the maintenance window. | `bool` | `true` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | Must be specified if multi\_az = false | `string` | `null` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | n/a | `number` | `7` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | When AWS can run snapshot, can't overlap with maintenance window | `string` | `"22:00-03:00"` | no |
| <a name="input_ca_cert_identifier"></a> [ca\_cert\_identifier](#input\_ca\_cert\_identifier) | Specifies the identifier of the CA certificate for the DB | `string` | `"rds-ca-rsa2048-g1"` | no |
| <a name="input_copy_tags_to_snapshot"></a> [copy\_tags\_to\_snapshot](#input\_copy\_tags\_to\_snapshot) | Copy all RDS Instance tags to snapshots. | `bool` | `true` | no |
| <a name="input_database_user"></a> [database\_user](#input\_database\_user) | The username for the RDS to be created | `string` | `"root"` | no |
| <a name="input_db_subnet_group_name"></a> [db\_subnet\_group\_name](#input\_db\_subnet\_group\_name) | The name of the DB subnet group to use. | `string` | `null` | no |
| <a name="input_dedicated_log_volume"></a> [dedicated\_log\_volume](#input\_dedicated\_log\_volume) | Use a dedicated log volume (DLV) for the DB instance. Requires Provisioned IOPS. | `bool` | `null` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Enables deletion protection for the RDS instance. When set to true, the instance cannot be deleted unless this setting is disabled. | `bool` | `true` | no |
| <a name="input_enabled_cloudwatch_logs_exports"></a> [enabled\_cloudwatch\_logs\_exports](#input\_enabled\_cloudwatch\_logs\_exports) | Set of log types to enable for exporting to CloudWatch logs. | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, staging, prod) | `string` | n/a | yes |
| <a name="input_instances"></a> [instances](#input\_instances) | A map of RDS instance configurations. | <pre>map(object({<br/>    allowed_cidr_blocks             = optional(list(string), [])<br/>    auto_minor_version_upgrade      = bool<br/>    availability_zone               = optional(string, null)<br/>    allocated_storage               = number<br/>    backup_retention_period         = number<br/>    backup_window                   = string<br/>    ca_cert_identifier              = string<br/>    copy_tags_to_snapshot           = bool<br/>    database_name                   = string<br/>    database_user                   = string<br/>    dedicated_log_volume            = optional(bool)<br/>    deletion_protection             = bool<br/>    enabled_cloudwatch_logs_exports = optional(list(string), [])<br/>    engine                          = string<br/>    engine_version                  = string<br/>    environment                     = string<br/>    final_snapshot_identifier       = optional(string, null)<br/>    instance_class                  = string<br/>    iops                            = optional(number, null)<br/>    kms_key_id                      = optional(string, null)<br/>    maintenance_window              = string<br/>    manage_master_user_password     = bool<br/>    max_allocated_storage           = optional(number, null)<br/>    multi_az                        = bool<br/>    monitoring_interval             = optional(number, null)<br/>    monitoring_role_arn             = optional(string, null)<br/>    name                            = string<br/>    performance_insights_enabled    = bool<br/>    performance_insights_kms_key_id = optional(string, null)<br/>    project_name                    = string<br/>    skip_final_snapshot             = bool<br/>    snapshot_identifier             = optional(string)<br/>    storage_type                    = string<br/>    storage_encrypted               = bool<br/>    username                        = string<br/>  }))</pre> | n/a | yes |
| <a name="input_iops"></a> [iops](#input\_iops) | The amount of provisioned IOPS. Setting this implies a storage\_type of 'io1' or 'io2'. Can only be set when storage\_type is 'io1', 'io2' or 'gp3'. Cannot be specified for gp3 storage if the allocated\_storage value is below a per-engine threshold. | `number` | `null` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | Optional KMS key ARN to encrypt the RDS and Secrets Manager secrets | `string` | `null` | no |
| <a name="input_manage_master_user_password"></a> [manage\_master\_user\_password](#input\_manage\_master\_user\_password) | Set to true to allow RDS to manage the master user password in Secrets Manager. | `bool` | `true` | no |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | Specifies the maximum storage (in GiB) that Amazon RDS can automatically scale to for this DB instance. | `number` | `null` | no |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input\_monitoring\_interval) | The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60. | `number` | `null` | no |
| <a name="input_monitoring_role_arn"></a> [monitoring\_role\_arn](#input\_monitoring\_role\_arn) | ARN for the KMS key to encrypt Performance Insights data. When specifying performance\_insights\_kms\_key\_id, performance\_insights\_enabled needs to be set to true. | `string` | `null` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Determines whether RDS instance uses multi-az | `bool` | `true` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_performance_insights_kms_key_id"></a> [performance\_insights\_kms\_key\_id](#input\_performance\_insights\_kms\_key\_id) | The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. | `string` | `null` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | n/a | yes |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | If true, the RDS will be publicly accessible | `bool` | `false` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | A map of existing security group IDs to use for the instances, keyed by the instance name. If not provided, new ones will be created. | `map(string)` | `null` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Determines whether a final DB snapshot is created before the DB instance is deleted | `bool` | `true` | no |
| <a name="input_snapshot_identifier"></a> [snapshot\_identifier](#input\_snapshot\_identifier) | Specifies whether or not to create this database from a snapshot. | `string` | `null` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Specifies whether the RDS instance storage is encrypted | `bool` | `true` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | One of 'standard' (magnetic), 'gp2' (general purpose SSD), 'gp3' (new generation of general purpose SSD), or 'io1' (provisioned IOPS SSD). | `string` | `"gp3"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnet IDs for the DB Subnet Group. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The following tags must be applied to all resources: cost-centre, account-code, portfolio-id, project-id, service-id, environment-type, owner-business and budget-holder | <pre>object({<br/>    cost-centre      = string<br/>    account-code     = string<br/>    portfolio-id     = string<br/>    project-id       = string<br/>    service-id       = string<br/>    environment-type = string<br/>    owner-business   = string<br/>    budget-holder    = string<br/>  })</pre> | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where RDS instance will be created | `string` | n/a | yes |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | A list of additional VPC security group IDs. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoints"></a> [endpoints](#output\_endpoints) | A map of connection endpoints for all RDS instances |
| <a name="output_instance_ids"></a> [instance\_ids](#output\_instance\_ids) | A map of RDS instance IDs |
| <a name="output_rds_instance_ids"></a> [rds\_instance\_ids](#output\_rds\_instance\_ids) | A map of RDS instance IDs |
| <a name="output_security_group_ids"></a> [security\_group\_ids](#output\_security\_group\_ids) | n/a |