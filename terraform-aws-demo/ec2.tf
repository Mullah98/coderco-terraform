resource "aws_instance" "this" {
  ami                     = "ami-0a0ff88d0f3f85a14"
  instance_type           = var.instance_type
}

resource "aws_instance" "import" {
  ami                     = "ami-0a0ff88d0f3f85a14"
  instance_type           = var.instance_type
  tags = {
    Name = "terraform-import"
  }
}