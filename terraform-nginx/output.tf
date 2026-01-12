output "nginx_public_ip" {
  description = "Public IP of the NGINX EC2 instance"
  value = aws_instance.nginx-server.public_ip
}

output "nginx_public_dns" {
  description = "Public DNS of the NGINX EC2 instance"
  value = aws_instance.nginx-server.public_dns
}