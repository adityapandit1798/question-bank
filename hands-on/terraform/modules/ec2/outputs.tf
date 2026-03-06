output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.this.public_ip
}

output "private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.this.private_ip
}

output "ebs_volume_id" {
  description = "ID of the attached EBS volume"
  value       = aws_ebs_volume.data.id
}

output "availability_zone" {
  description = "AZ where the instance is running"
  value       = aws_instance.this.availability_zone
}
