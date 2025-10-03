output "instance_id" {
  value = aws_instance.terraform_demo.id
}

output "instance_public_ip" {
  value = aws_instance.terraform_demo.public_ip
}
