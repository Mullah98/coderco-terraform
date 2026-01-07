variable "instance_type" {
  type = string
}

locals {
  instance_ami = "ami-0a0ff88d0f3f85a14"
}

output "instance_id" {
  description = "The ID of the EC2 instance"
  value = aws_instance.this.id
}