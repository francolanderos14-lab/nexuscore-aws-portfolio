output "db_endpoint" { value = aws_db_instance.main.endpoint }
output "db_address" { value = aws_db_instance.main.address }
output "db_name" { value = aws_db_instance.main.db_name }
output "db_username" { value = aws_db_instance.main.username }
output "db_port" { value = aws_db_instance.main.port }