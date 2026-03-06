variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "environment" {
  description = "Environment name (dev, qa, prod)"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name for EC2 access"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID to launch the instance in"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "private_key_path" {
  description = "Path to the SSH private key for provisioners"
  type        = string
}

variable "script_path" {
  description = "Path to the shell script for remote-exec"
  type        = string
  default     = ""
}

variable "upload_source" {
  description = "Local path of the file to copy via file provisioner"
  type        = string
  default     = ""
}

variable "upload_destination" {
  description = "Remote path for the uploaded file"
  type        = string
  default     = "/tmp/config.txt"
}

variable "ebs_volume_size" {
  description = "Size of the EBS volume in GB"
  type        = number
  default     = 10
}

variable "ebs_volume_type" {
  description = "EBS volume type (gp2, gp3, io1, io2, st1, sc1)"
  type        = string
  default     = "gp3"
}

variable "ebs_availability_zone" {
  description = "AZ for the EBS volume (must match the instance AZ)"
  type        = string
}

variable "prevent_destroy" {
  description = "Enable prevent_destroy lifecycle on the instance"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}
