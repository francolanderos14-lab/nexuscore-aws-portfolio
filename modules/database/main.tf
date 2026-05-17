resource "aws_db_subnet_group" "main" {
  name       = "nexuscore-db-subnet-group"
  subnet_ids = var.private_db_subnet_ids
  tags       = { Name = "NexusCore_db_subnet_group" }
}

resource "aws_db_parameter_group" "mysql" {
  name   = "nexuscore-mysql-params"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "2"
  }

  tags = { Name = "NexusCore_db_parameter_group" }
}

resource "aws_db_instance" "main" {
  identifier     = "nexuscore-mysql"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 20
  storage_type          = "gp2"
  storage_encrypted     = true
  kms_key_id            = var.kms_key_arn

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_sg_id]
  publicly_accessible    = false
  parameter_group_name   = aws_db_parameter_group.mysql.name

  backup_retention_period = 1
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  deletion_protection = false
  skip_final_snapshot = true
  multi_az            = false

  enabled_cloudwatch_logs_exports = ["error", "slowquery"]

  tags = { Name = "NexusCore_rds_mysql" }
}