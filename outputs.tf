output "endpoint" {
  value = aws_db_instance.this.endpoint
}

output "rds_arn" {
  value = aws_db_instance.this.arn
}

output "secret_arn" {
  value = aws_secretsmanager_secret.custom[0].arn
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
