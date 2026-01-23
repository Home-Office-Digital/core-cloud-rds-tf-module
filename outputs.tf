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

output "security_group_ids" {
  value     = { for k, v in aws_security_group.this : k => v.id }
  sensitive = true
}
