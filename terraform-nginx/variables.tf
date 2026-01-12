variable "ami_id" {
  description = "Ubuntu AMI for EC2 instance"
  type = string
  default = "ami-0a0ff88d0f3f85a14"
}

variable "instance_type" {
  description = "Instance type for EC2 instance"
  type = string
  default = "t3.micro"
}