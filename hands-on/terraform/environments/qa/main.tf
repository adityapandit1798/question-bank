provider "aws" {
  region = var.aws_region
}

module "ec2" {
  source = "../../modules/ec2"

  ami_id                = var.ami_id
  instance_type         = var.instance_type
  environment           = "qa"
  key_name              = var.key_name
  subnet_id             = var.subnet_id
  security_group_ids    = var.security_group_ids
  private_key_path      = var.private_key_path
  script_path           = "../../scripts/setup.sh"
  upload_source         = "../../files/config.txt"
  upload_destination    = "/tmp/config.txt"
  ebs_volume_size       = 20
  ebs_volume_type       = "gp3"
  ebs_availability_zone = var.availability_zone

  tags = {
    ManagedBy = "terraform"
  }
}

output "instance_id" {
  value = module.ec2.instance_id
}

output "public_ip" {
  value = module.ec2.public_ip
}
