variable "project_name" {
    description = "Describes the name of the Project"
    type = string
    default = "terraform-project"
}

variable "vpc_cidr" {
    description = "CIDR Block for VPC"
    type = string
    default = "10.0.0.0/16"

    validation {
      condition = can(cidrhost(var.vpc_cidr, 0))
      error_message = "VPC CIDR must be a valid IPv4 CIDR block."
    }
}

variable "subnet_cidr" {
    description = "CIDR Block for public subnet"
    type = string
    default = "10.0.1.0/24"

    validation {
      condition = can(cidrhost(var.subnet_cidr, 0))
      error_message = "Subnet CIDR must be a valid IPv4 CIDR block."
    }
}

variable "enable_dns_hostnames" {
    description = "Enable DNS hostnames in VPC"
    type =bool
    default = true
}

variable "enable_dns_support" {
    description = "Enable DNS support in VPC"
    type = bool
    default = true
}

variable "instance_type" {
     description = "EC2 Instance Type"
     type = string
     default = "t3.micro"
}

variable "root_volume_size" {
     description = "Size of Root EBS volume in GB"
     type = number
     default = 20

     validation {
       condition = var.root_volume_size >= 8 && var.root_volume_size <= 100
       error_message = "Root Volume size must be in between 8 GB and 100 GB"
     }
}

variable "root_volume_type" {
     description = "Type of Root EBS Volume"
     type = string
     default = "gp3"

     validation {
       condition = contains(["gp2", "gp3", "io1", "io2"], var/root_volume_type)
       error_message = "Volume Type must be gp2, gp3, io1 or io2"
     }
}

variable "enable_root_encryption" {
     description = "Enable Root Encryption"
     type = bool
     default = true
}

variable "key_name" {
     description = "Name of SSH KeyPair"
     type = string
     default = "terraform-key"
}

variable "ssh_public_key_path" {
     description = "Path to SSH Public Key File"
     type = string
     default = "~/.ssh/terraform-key.pub"
}

variable "enable_s3_versioning" {
     description = "Enable S3 Bucket Versioning"
     type = string
     default = "Enabled"

     validation {
       condition = contains(["Enabled", "Disabled"], var.enable_s3_versioning)
       error_message = "Must Be Either Enabled or Disabled"
     }
}

variable "s3_encryption_algorithm" {
     description = "Enable S3 Encryption"
     type = string
     default = "AES256"
}