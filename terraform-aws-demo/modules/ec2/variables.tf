variable "instance_type" {
  type = string
}

variable "instance_ami" {
  type = string
}


output "instance_id" {
  description = "The ID of the EC2 instance"
  value = aws_instance.this.id
}