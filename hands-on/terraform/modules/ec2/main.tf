terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# -------------------------------------------------------------------
# EC2 Instance with provisioners and lifecycle protection
# -------------------------------------------------------------------
resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  tags = merge(var.tags, {
    Name        = "${var.environment}-ec2"
    Environment = var.environment
  })

  # --- File provisioner: copy a local file to the instance ----------
  provisioner "file" {
    source      = var.upload_source
    destination = var.upload_destination

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }

  # --- Remote-exec provisioner: run a shell script on the instance --
  provisioner "remote-exec" {
    script = var.script_path

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }

  # prevent_destroy  = true   → prevents accidental deletion via terraform destroy
  # create_before_destroy     → creates replacement before destroying old (zero-downtime)
  lifecycle {
    prevent_destroy       = true
    create_before_destroy = true
  }
}

# -------------------------------------------------------------------
# EBS Volume — created separately so its type can be changed in-place
# -------------------------------------------------------------------
resource "aws_ebs_volume" "data" {
  availability_zone = var.ebs_availability_zone
  size              = var.ebs_volume_size
  type              = var.ebs_volume_type

  tags = merge(var.tags, {
    Name        = "${var.environment}-ebs-data"
    Environment = var.environment
  })

  # Changing volume type (e.g. gp2 → gp3) triggers an in-place
  # modification — AWS handles this without data loss.  We also
  # guard against accidental destruction of the volume.
  lifecycle {
    prevent_destroy = true
  }
}

# -------------------------------------------------------------------
# Attach the EBS volume to the EC2 instance
# -------------------------------------------------------------------
resource "aws_volume_attachment" "data_att" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.this.id

  force_detach = true
}
