resource "aws_instance" "wordpress" {
  ami = var.ami_id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.wordpress_security_group.id] ## Referencing the security group resource block on line 8
}

## Creating security group to allow incoming traffic to port 80 and port 443
resource "aws_security_group" "wordpress_security_group" {

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}