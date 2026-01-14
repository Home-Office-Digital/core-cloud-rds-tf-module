output "rds_instance_ids" {
  value = { for k, v in aws_db_instance.this : k => v.id }
  sensitive = true
}

output "endpoint" {
  value = { for k, instance in aws_db_instance.this : k => instance.endpoint }
  sensitive = true
}

output "instance_ids" {
  value = { for k, instance in aws_db_instance.this : k => instance.id }
  sensitive = true
}

output "secret_arn" {
  value = aws_secretsmanager_secret.custom[0].arn
  sensitive = true
}

output "generated_password" {
  description = "Module generated RDS password"
  value       = local.aws_managed_password
  sensitive   = true
}

output "security_group_ids" {
  value     = { for k, v in aws_security_group.this : k => v.id }
  sensitive = true
}
