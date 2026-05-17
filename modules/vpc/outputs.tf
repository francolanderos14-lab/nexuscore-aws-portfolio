output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_compute_subnet_ids" {
  value = aws_subnet.private_compute[*].id
}

output "private_db_subnet_ids" {
  value = aws_subnet.private_db[*].id
}

output "private_compute_route_table_id" {
  value = aws_route_table.private_compute.id
}