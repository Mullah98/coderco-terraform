resource "aws_instance" "this" {
  ami                     = "ami-0a0ff88d0f3f85a14"
  instance_type           = "t3.micro"
}

resource "aws_instance" "import" {
  ami                     = "ami-0a0ff88d0f3f85a14"
  instance_type           = "t3.micro"
  tags = {
    Name = "terraform-import"
  }
}