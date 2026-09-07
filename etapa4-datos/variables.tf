variable "region" {
  type    = string
  default = "us-east-1"
}

variable "nombre_proyecto" {
  type    = string
  default = "lab-tf"
}

variable "alumno" {
  type = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.alumno))
    error_message = "Use solo minúsculas, dígitos y guiones."
  }
}

variable "vpc_cidr" {
  description = "Bloque CIDR de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "num_instancias" {
  description = "Instancias deseadas en el Auto Scaling Group"
  type        = number
  default     = 2
}

variable "habilitar_nat" {
  description = "Crear NAT Gateway (tiene costo por hora). Necesario para que las instancias privadas instalen paquetes."
  type        = bool
  default     = true
}

variable "db_instance_class" {
  description = "Clase de instancia RDS (db.t4g.micro y db.t3.micro son elegibles para capa gratuita)"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_nombre" {
  type    = string
  default = "appdb"
}

variable "db_usuario" {
  type    = string
  default = "appadmin"
}

variable "db_multi_az" {
  description = "Réplica síncrona en otra AZ (duplica el costo; solo prod real)"
  type        = bool
  default     = false
}

variable "db_backup_retention_days" {
  type    = number
  default = 0
}

variable "db_deletion_protection" {
  type    = bool
  default = false
}
