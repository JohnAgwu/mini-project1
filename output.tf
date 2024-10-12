# Output Public DNS for all instances and RDS endpoint
output "frontend1_public_dns" {
  value = aws_instance.frontend1.public_dns
}

output "frontend2_public_dns" {
  value = aws_instance.frontend2.public_dns
}

output "backend1_public_dns" {
  value = aws_instance.backend1.public_dns
}

output "backend2_public_dns" {
  value = aws_instance.backend2.public_dns
}

output "mysql_instance_public_dns" {
  value = aws_instance.mysql_instance.public_dns
}

output "rds_endpoint" {
  value = aws_db_instance.mysql_db.endpoint
}