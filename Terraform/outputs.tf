output "ec2_public_ip" {
  value = aws_instance.flask_instance.public_ip
}

output "rds_endpoint" {
  value = split(":", aws_db_instance.postgres.endpoint)[0]
}