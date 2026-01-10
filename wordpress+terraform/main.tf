## EC2 instance for WordPress
resource "aws_instance" "wordpress" {
  ami = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.wordpress_security_group.id]
  associate_public_ip_address = true

  user_data = file("${path.module}/userdata.sh")

  tags = {
    Name = "wordpress-ec2"
  }
}

## Security group for Wordpress server
resource "aws_security_group" "wordpress_security_group" {

  ## Allow HTTP traffic
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
    Name = "wordpress-sg"
  }
}