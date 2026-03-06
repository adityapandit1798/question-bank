output "private_subnets" {
  description = "Public IP of the EC2 instance"
  value = aws.this.private_subnets
}