variable "aws_region" {
  description = "Region AWS donde se despliega la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefijo para identificar todos los recursos NexusCore"
  type        = string
  default     = "nexuscore"
}

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
  default     = "dev"
}

variable "your_ip" {
  description = "Tu IP publica para acceso SSH al Bastion (formato x.x.x.x/32)"
  type        = string
}

variable "key_pair_name" {
  description = "Nombre del Key Pair creado en la consola AWS"
  type        = string
}

variable "db_password" {
  description = "Contrasena maestra de RDS MySQL"
  type        = string
  sensitive   = true
}

variable "alert_email" {
  description = "Email para recibir alertas de CloudWatch"
  type        = string
}