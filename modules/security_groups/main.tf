resource "aws_security_group" "alb" {
  name        = "NexusCore_sg_alb"
  description = "Trafico publico entrante al Application Load Balancer"
  vpc_id      = var.vpc_id
  tags        = { Name = "NexusCore_sg_alb" }
}

resource "aws_security_group" "ec2" {
  name        = "NexusCore_sg_ec2"
  description = "Instancias privadas del Auto Scaling Group"
  vpc_id      = var.vpc_id
  tags        = { Name = "NexusCore_sg_ec2" }
}

resource "aws_security_group" "rds" {
  name        = "NexusCore_sg_rds"
  description = "MySQL accesible solo desde instancias EC2"
  vpc_id      = var.vpc_id
  tags        = { Name = "NexusCore_sg_rds" }
}

resource "aws_security_group" "nat" {
  name        = "NexusCore_sg_nat"
  description = "NAT Instance: reenvio de trafico privado hacia internet"
  vpc_id      = var.vpc_id
  tags        = { Name = "NexusCore_sg_nat" }
}

resource "aws_security_group" "bastion" {
  name        = "NexusCore_sg_bastion"
  description = "SSH restringido exclusivamente al administrador"
  vpc_id      = var.vpc_id
  tags        = { Name = "NexusCore_sg_bastion" }
}

# ─── REGLAS ALB ───────────────────────────────────────
resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
  description       = "HTTP desde internet"
}

resource "aws_security_group_rule" "alb_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
  description       = "HTTPS desde internet"
}

resource "aws_security_group_rule" "alb_egress_ec2" {
  type                     = "egress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2.id
  security_group_id        = aws_security_group.alb.id
  description              = "Trafico hacia instancias EC2 del ASG"
}

# ─── REGLAS EC2 ───────────────────────────────────────
resource "aws_security_group_rule" "ec2_ingress_alb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ec2.id
  description              = "Trafico desde el ALB unicamente"
}

resource "aws_security_group_rule" "ec2_ingress_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.ec2.id
  description              = "SSH solo desde el Bastion Host"
}

resource "aws_security_group_rule" "ec2_egress_rds" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds.id
  security_group_id        = aws_security_group.ec2.id
  description              = "Conexion MySQL hacia RDS"
}

resource "aws_security_group_rule" "ec2_egress_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2.id
  description       = "HTTPS hacia internet via NAT Instance"
}

resource "aws_security_group_rule" "ec2_egress_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2.id
  description       = "HTTP via NAT Instance"
}

# ─── REGLAS RDS ───────────────────────────────────────
resource "aws_security_group_rule" "rds_ingress_ec2" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2.id
  security_group_id        = aws_security_group.rds.id
  description              = "MySQL desde instancias EC2 del ASG"
}

# ─── REGLAS NAT ───────────────────────────────────────
resource "aws_security_group_rule" "nat_ingress_privadas" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["10.0.2.0/24", "10.0.3.0/24"]
  security_group_id = aws_security_group.nat.id
  description       = "Todo trafico desde subredes privadas de computo"
}

resource "aws_security_group_rule" "nat_egress_internet" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nat.id
  description       = "Reenvio hacia internet"
}

# ─── REGLAS BASTION ───────────────────────────────────
resource "aws_security_group_rule" "bastion_ingress_admin" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.your_ip]
  security_group_id = aws_security_group.bastion.id
  description       = "SSH solo desde IP del administrador"
}

resource "aws_security_group_rule" "bastion_egress_privadas" {
  type              = "egress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["10.0.2.0/24", "10.0.3.0/24"]
  security_group_id = aws_security_group.bastion.id
  description       = "SSH hacia subredes privadas de computo"
}
resource "aws_security_group_rule" "bastion_egress_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
  description       = "HTTPS hacia internet para instalar paquetes"
}

resource "aws_security_group_rule" "bastion_egress_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
  description       = "HTTP hacia internet"
}

resource "aws_security_group_rule" "bastion_egress_rds" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds.id
  security_group_id        = aws_security_group.bastion.id
  description              = "MySQL hacia RDS desde Bastion"
}

resource "aws_security_group_rule" "rds_ingress_bastion" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.rds.id
  description              = "MySQL desde Bastion Host"
}