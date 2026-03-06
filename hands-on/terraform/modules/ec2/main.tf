terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# -------------------------------------------------------------------
# EC2 Instance via official Terraform registry module
# -------------------------------------------------------------------
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  name                   = "${var.environment}-ec2"
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  create_eip = false

  tags = merge(var.tags, {
    Environment = var.environment
  })

  # zero-downtime: create replacement before destroying old
  lifecycle {
    create_before_destroy = true
  }
}

# -------------------------------------------------------------------
# Provisioners require a connection to the instance, which the
# registry module doesn't expose.  A null_resource triggers them
# once the instance is ready.
# -------------------------------------------------------------------
resource "null_resource" "provisioners" {
  depends_on = [module.ec2_instance]

  triggers = {
    instance_id = module.ec2_instance.id
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.private_key_path)
    host        = module.ec2_instance.public_ip
  }

  # file provisioner: copy a local file to the instance
  provisioner "file" {
    source      = var.upload_source
    destination = var.upload_destination
  }

  # remote-exec provisioner: run a shell script on the instance
  provisioner "remote-exec" {
    script = var.script_path
  }
}

# -------------------------------------------------------------------
# EBS Volume - created separately so its type can be changed in-place
# without data loss (AWS handles gp2 -> gp3 as an online modification)
# -------------------------------------------------------------------
resource "aws_ebs_volume" "data" {
  availability_zone = var.ebs_availability_zone
  size              = var.ebs_volume_size
  type              = var.ebs_volume_type

  tags = merge(var.tags, {
    Name        = "${var.environment}-ebs-data"
    Environment = var.environment
  })

  lifecycle {
    prevent_destroy = true
  }
}

# -------------------------------------------------------------------
# Attach the EBS volume to the EC2 instance
# -------------------------------------------------------------------
resource "aws_volume_attachment" "data_att" {
  device_name  = "/dev/xvdf"
  volume_id    = aws_ebs_volume.data.id
  instance_id  = module.ec2_instance.id
  force_detach = true
}
