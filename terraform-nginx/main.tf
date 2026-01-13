resource "aws_instance" "nginx-server" {
  ami = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.nginx_security_group.id]
  associate_public_ip_address = true

  user_data = file("${path.module}/user-data.yaml")

  tags = {
    Name = "nginx-server"
  }
}

## Security group for EC2 instance
resource "aws_security_group" "nginx_security_group" {
  
  ## Allow inbound HTTP traffic
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ## Allow all outbound traffic
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx-security-group"
  }
}