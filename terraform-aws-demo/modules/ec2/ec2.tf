resource "aws_instance" "this" {
  ami                     = var.instance_ami
  instance_type           = var.instance_type
}

resource "aws_instance" "import" {
  ami                     = var.instance_ami
  instance_type           = var.instance_type
  tags = {
    Name = "terraform-import"
  }
}