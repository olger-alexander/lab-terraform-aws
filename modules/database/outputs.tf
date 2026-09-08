output "db_endpoint" {
  value = aws_db_instance.postgres.address
}

output "db_password_ssm" {
  value = aws_ssm_parameter.db_password.name
}
