output "wordpress_public_ip" {
  description = "Public IP of the Wordpress EC2 instance"
  value = aws_instance.wordpress.public_ip
}

output "wordpress_public_dns" {
  description = "Public DNS of the Wordpress Ec2 instnce"
  value = aws_instance.wordpress.public_dns
}