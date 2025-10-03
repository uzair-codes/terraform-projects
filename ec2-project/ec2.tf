resource "aws_instance" "terraform_demo" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name = "publi-key"

  tags = {
    Name = "Terraform-EC2"
  }
}
