output "asg_name" { value = aws_autoscaling_group.app.name }
output "asg_arn" { value = aws_autoscaling_group.app.arn }
output "alb_dns_name" { value = aws_lb.main.dns_name }
output "alb_arn_suffix" { value = aws_lb.main.arn_suffix }
output "launch_template_id" { value = aws_launch_template.app.id }