variable "ami_id" {
  description = "Ubuntu AMI for EC2 Instance"
  type = string
  default = "ami-0a0ff88d0f3f85a14"
}

variable "instance_type" {
  description = "EC2 instance type"
  type = string
  default = "t3.micro"
}