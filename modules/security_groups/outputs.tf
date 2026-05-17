output "alb_sg_id" { value = aws_security_group.alb.id }
output "ec2_sg_id" { value = aws_security_group.ec2.id }
output "rds_sg_id" { value = aws_security_group.rds.id }
output "nat_sg_id" { value = aws_security_group.nat.id }
output "bastion_sg_id" { value = aws_security_group.bastion.id }