output "rds_instance_ids" {
  description = "A map of RDS instance IDs"
  value       = merge({ for k, v in aws_db_instance.this : k => v.id })
  sensitive   = true
}

output "endpoints" {
  description = "A map of connection endpoints for all RDS instances"
  value = merge(
  { for k, instance in aws_db_instance.this : k => instance.endpoint })
  sensitive = true
}

output "instance_ids" {
  description = "A map of RDS instance IDs"
  value       = merge({ for k, instance in aws_db_instance.this : k => instance.id })
  sensitive   = true
}

output "rds_password_secrets" {
  description = "A map of Secrets Manager ARNs for RDS passwords"
  value       = { for k, v in aws_secretsmanager_secret.rds_password : k => v.arn if contains(keys(aws_secretsmanager_secret.rds_password), k) }
  sensitive   = true
}

output "security_group_ids" {
  value     = { for k, v in aws_security_group.this : k => v.id }
  sensitive = true
}
