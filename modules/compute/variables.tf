variable "project_name" { type = string }
variable "ami_id" { type = string }
variable "key_pair_name" { type = string }
variable "ec2_sg_id" { type = string }
variable "alb_sg_id" { type = string }
variable "private_compute_subnet_ids" { type = list(string) }
variable "public_subnet_ids" { type = list(string) }
variable "vpc_id" { type = string }
variable "kms_key_arn" { type = string }
variable "db_endpoint" { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}