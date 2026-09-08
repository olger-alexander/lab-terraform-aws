terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

resource "aws_security_group" "db" {
  name        = "${var.prefijo}-sg-db"
  description = "PostgreSQL solo desde la capa de aplicacion"
  vpc_id      = var.vpc_id
  tags        = { Name = "${var.prefijo}-sg-db" }
}

resource "aws_vpc_security_group_ingress_rule" "db_desde_app" {
  security_group_id            = aws_security_group.db.id
  description                  = "PostgreSQL solo desde el SG de la app"
  referenced_security_group_id = var.sg_app_id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "random_password" "db" {
  length  = 24
  special = false
}

resource "aws_ssm_parameter" "db_password" {
  #checkov:skip=CKV_AWS_337:Usa la clave por defecto de SSM (aws/ssm); una CMK dedicada tiene costo adicional
  name  = "/${var.prefijo}/db/password"
  type  = "SecureString"
  value = random_password.db.result
}

resource "aws_ssm_parameter" "db_endpoint" {
  name  = "/${var.prefijo}/db/endpoint"
  type  = "SecureString"
  value = aws_db_instance.postgres.address
}

resource "aws_db_subnet_group" "db" {
  name       = "${var.prefijo}-dbsubnets"
  subnet_ids = var.subnets_privadas_ids
}

resource "aws_db_instance" "postgres" {
  #checkov:skip=CKV_AWS_118:Monitoreo mejorado tiene costo adicional, fuera de alcance del laboratorio
  #checkov:skip=CKV_AWS_157:Multi-AZ duplica el costo; decision explicita del laboratorio (ver db_multi_az)
  #checkov:skip=CKV_AWS_161:Autenticacion IAM para RDS es una mejora fuera del alcance de este laboratorio
  #checkov:skip=CKV_AWS_293:Laboratorio efimero que se destruye en cada sesion (ver ejercicio 4.6)
  #checkov:skip=CKV_AWS_353:Performance Insights tiene costo adicional, fuera de alcance
  #checkov:skip=CKV_AWS_133:backup_retention_period=0 es una decision explicita del laboratorio
  #checkov:skip=CKV2_AWS_30:Requiere un parameter group personalizado, fuera de alcance de este laboratorio
  identifier                      = "${var.prefijo}-db"
  engine                          = "postgres"
  engine_version                  = "16"
  instance_class                  = var.db_instance_class
  allocated_storage                = 20
  storage_type                     = "gp2"
  storage_encrypted                = true
  db_name                          = var.db_nombre
  username                         = var.db_usuario
  password                         = random_password.db.result
  db_subnet_group_name             = aws_db_subnet_group.db.name
  vpc_security_group_ids           = [aws_security_group.db.id]
  publicly_accessible              = false
  multi_az                         = var.db_multi_az
  auto_minor_version_upgrade       = true
  copy_tags_to_snapshot            = true
  enabled_cloudwatch_logs_exports  = ["postgresql", "upgrade"]

  backup_retention_period = 0
  deletion_protection     = false
  skip_final_snapshot     = true
  apply_immediately        = true

  tags = { Name = "${var.prefijo}-db" }
}
