#resource "random_password" "db" {
#  length  = 24
#  special = false
#}

#resource "aws_ssm_parameter" "db_password" {
#  name  = "/${local.prefijo}/db/password"
#  type  = "SecureString"
#  value = random_password.db.result
#}

#resource "aws_ssm_parameter" "db_endpoint" {
#  name  = "/${local.prefijo}/db/endpoint"
#  type  = "String"
#  value = aws_db_instance.postgres.address
#}

resource "aws_db_subnet_group" "db" {
  name       = "${local.prefijo}-dbsubnets"
  subnet_ids = [for s in aws_subnet.privada : s.id]
}

resource "aws_db_instance" "postgres" {
  identifier              = "${local.prefijo}-db"
  engine                  = "postgres"
  engine_version          = "16"
  instance_class          = var.db_instance_class
  allocated_storage       = 20
  storage_type            = "gp2"
  storage_encrypted       = true
  #password_wo         = random_password.db.result
  #password_wo_version = 1
  db_name                 = var.db_nombre
  username                = var.db_usuario
  manage_master_user_password = true   
  db_subnet_group_name    = aws_db_subnet_group.db.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  publicly_accessible     = false
  multi_az                = var.db_multi_az

  backup_retention_period = 7
  deletion_protection     = true
  skip_final_snapshot     = true
  apply_immediately       = true

  tags = { Name = "${local.prefijo}-db" }
}
