output "instance_id" {
  value = aws_instance.web[*].id
}

output "ip_publica" {
  value = aws_instance.web[*].public_ip
}

output "url" {
  value = [for i in aws_instance.web : "http://${i.public_dns}:${var.puerto_http}"]
}
