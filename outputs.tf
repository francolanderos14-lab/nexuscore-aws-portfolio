output "alb_dns_name" {
  description = "URL para acceder a la aplicacion WordPress"
  value       = module.compute.alb_dns_name
}

output "bastion_public_ip" {
  description = "IP publica del Bastion Host para conexion SSH"
  value       = module.bastion.bastion_public_ip
}

output "nat_public_ip" {
  description = "IP publica de la NAT Instance"
  value       = module.nat_instance.nat_public_ip
}

output "db_endpoint" {
  description = "Endpoint de RDS para el script de datos simulados"
  value       = module.database.db_endpoint
  sensitive   = true
}

output "cloudtrail_bucket" {
  description = "Bucket S3 con los logs de auditoria CloudTrail"
  value       = module.monitoring.cloudtrail_bucket
}