All notable changes to this project will be documented in this file. This will provide a record of all notable module updates with each new release. Semantic versioning (https://semver.org/) must be adhered to for all Core Cloud modules.

eg:

### [0.0.1] 2025-11-27

  * Initial tag created for Core Cloud RDS Terraform module

### [0.0.2] 2025-12-15

  * Var validation condition updates and aligned tags with current mandatory Core Cloud Tags

### [0.0.3] 2025-12-15

  * Removal of var validation condition and addition of secret_name var

### [0.0.4] 2026-01-06

  * Update of lifecycle preconditions

### [0.0.5] 2026-01-16

  * Addition of TFLint workflow step and bumping Checkov and Sonar scan versions

### [0.0.6] 2026-01-16

  * Adjusting instances variable optional parameters

### [0.0.7] 2026-01-16

  * Further adjustments of instances variable optional parameters

### [0.0.8] 2026-01-16

  * Adjusting variables' conditions

### [0.0.9] 2026-01-16

  * Removal of var validation - opting for default values

### [0.0.10] 2026-01-16

  * Updating ReadMe example configuration

### [0.0.11] 2026-01-19

  * ReadMe, Output description and SAST Workflow TF version update

### [0.0.12] 2026-01-19

  * Update Changelog to relect recent updates

### [0.0.13] 2026-01-19

  * Update Codeowners, RDS Password prefix and Changelog

### [0.0.14] 2026-01-19

  * Update egress logic, restricting to user defined cidr

### [0.0.15] 2026-01-20

  * Updating tags, adding RDS variables, secret rotation functionality and security group logic

### [0.0.16] 2026-01-20

  * Adding RDS variables and secret rotation functionality

### [0.0.17] 2026-01-21

  * Adding RDS variables - max_allocated_storage & manage_master_user_password. Adjusting secret rotation logic.