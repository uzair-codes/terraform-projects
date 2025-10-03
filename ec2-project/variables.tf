variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
  default     = "ami-02d26659fd82cf299"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "vpc_id" {
  description = "VPC ID where the instance will be created"
  type        = string
  default     = "vpc-01f72e76d9807c46b" # Replace with your VPC ID
}
