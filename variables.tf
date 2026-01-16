variable "instances" {
  description = "A map of RDS instance configurations."
  type = map(object({
    allowed_cidr_blocks             = optional(list(string), [])
    auto_minor_version_upgrade      = bool
    availability_zone               = optional(string, null)
    allocated_storage               = number
    backup_retention_period         = number
    backup_window                   = string
    ca_cert_identifier              = string
    database_name                   = string
    database_user                   = string
    deletion_protection             = bool
    enabled_cloudwatch_logs_exports = optional(list(string), [])
    engine                          = string
    engine_version                  = string
    environment                     = string
    final_snapshot_identifier       = optional(string, null)
    instance_class                  = string
    iops                            = optional(number, null)
    kms_key_id                      = optional(string, null)
    maintenance_window              = string
    multi_az                        = bool
    name                            = string
    performance_insights_enabled    = bool
    project_name                    = string
    skip_final_snapshot             = bool
    snapshot_identifier             = optional(string)
    storage_type                    = string
    storage_encrypted               = bool
    username                        = string
  }))
}

variable "ca_cert_identifier" {
  type        = string
  default     = "rds-ca-rsa2048-g1"
  description = "Specifies the identifier of the CA certificate for the DB"
}

variable "availability_zone" {
  type        = string
  default     = null
  description = "Must be specified if multi_az = false"
}

variable "skip_final_snapshot" {
  type        = bool
  default     = true
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted"
}

variable "deletion_protection" {
  type        = bool
  default     = true
  description = "Enables deletion protection for the RDS instance. When set to true, the instance cannot be deleted unless this setting is disabled."
}

variable "backup_retention_period" {
  type    = number
  default = 7
}

variable "backup_window" {
  type        = string
  default     = "22:00-03:00"
  description = "When AWS can run snapshot, can't overlap with maintenance window"
}

variable "database_user" {
  type        = string
  default     = "root"
  description = "The username for the RDS to be created"
}

variable "snapshot_identifier" {
  type        = string
  default     = null
  description = "Specifies whether or not to create this database from a snapshot."
}

variable "storage_type" {
  default     = "gp3"
  type        = string
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), 'gp3' (new generation of general purpose SSD), or 'io1' (provisioned IOPS SSD)."
}

variable "performance_insights_enabled" {
  type    = bool
  default = true
}

variable "publicly_accessible" {
  description = "If true, the RDS will be publicly accessible"
  type        = bool
  default     = false
}

variable "db_subnet_group_name" {
  description = "The name of the DB subnet group to use."
  type        = string
  default     = null
}

variable "multi_az" {
  description = "Determines whether RDS instance uses multi-az"
  type        = bool
  default     = true
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the RDSÅ instance during the maintenance window."
  type        = bool
  default     = true
}

variable "storage_encrypted" {
  description = "Specifies whether the RDS instance storage is encrypted"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "Optional KMS key ARN to encrypt the RDS and Secrets Manager secrets"
  type        = string
  default     = null
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where RDS instance will be created"
  type        = string
}

variable "tags" {
  type = object({
    cost-centre      = string
    account-code     = string
    portfolio-id     = string
    project-id       = string
    service-id       = string
    environment-type = string
    owner-business   = string
    budget-holder    = string
    source-repo      = string
  })
  description = "The following tags must be applied to all resources: cost-centre, account-code, portfolio-id, project-id, service-id, environment-type, owner-business, budget-holder and source-repo"
  nullable    = false
}

variable "security_group_ids" {
  description = "A map of existing security group IDs to use for the instances, keyed by the instance name. If not provided, new ones will be created."
  type        = map(string)
  default     = null
}

variable "vpc_security_group_ids" {
  description = "A list of additional VPC security group IDs."
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the DB Subnet Group."
  type        = list(string)
  default     = []
}
