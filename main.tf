data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

module "kms" {
  source       = "./modules/kms"
  project_name = var.project_name
}

module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  environment  = var.environment
}

module "security_groups" {
  source       = "./modules/security_groups"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  your_ip      = var.your_ip
}

module "nat_instance" {
  source       = "./modules/nat_instance"
  project_name = var.project_name

  public_subnet_id               = module.vpc.public_subnet_ids[0]
  nat_sg_id                      = module.security_groups.nat_sg_id
  private_compute_route_table_id = module.vpc.private_compute_route_table_id
  kms_key_arn                    = module.kms.key_arn
  key_pair_name                  = var.key_pair_name
}

module "bastion" {
  source       = "./modules/bastion"
  project_name = var.project_name

  public_subnet_id = module.vpc.public_subnet_ids[0]
  bastion_sg_id    = module.security_groups.bastion_sg_id
  kms_key_arn      = module.kms.key_arn
  key_pair_name    = var.key_pair_name
}

module "database" {
  source       = "./modules/database"
  project_name = var.project_name

  private_db_subnet_ids = module.vpc.private_db_subnet_ids
  rds_sg_id             = module.security_groups.rds_sg_id
  kms_key_arn           = module.kms.key_arn
  db_password           = var.db_password
}

module "compute" {
  source       = "./modules/compute"
  project_name = var.project_name

  ami_id                     = data.aws_ami.amazon_linux_2.id
  key_pair_name              = var.key_pair_name
  ec2_sg_id                  = module.security_groups.ec2_sg_id
  alb_sg_id                  = module.security_groups.alb_sg_id
  private_compute_subnet_ids = module.vpc.private_compute_subnet_ids
  public_subnet_ids          = module.vpc.public_subnet_ids
  vpc_id                     = module.vpc.vpc_id
  kms_key_arn                = module.kms.key_arn
  db_endpoint                = module.database.db_endpoint
  db_password                = var.db_password
}

module "monitoring" {
  source       = "./modules/monitoring"
  project_name = var.project_name

  asg_name       = module.compute.asg_name
  rds_identifier = "${var.project_name}-mysql"
  alb_arn_suffix = module.compute.alb_arn_suffix
  alert_email    = var.alert_email
}

module "finops" {
  source       = "./modules/finops"
  project_name = var.project_name

  asg_name       = module.compute.asg_name
  rds_identifier = "${var.project_name}-mysql"
  sns_topic_arn  = module.monitoring.sns_topic_arn
}