variable "project_name" {
    description = "Describes the name of the Project"
    type = string
    # default = "terraform-project"
}

variable "igw_id" {
     type = string
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
       condition = contains(["gp2", "gp3", "io1", "io2"], var.root_volume_type)
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

variable "subnet_id" {
    description = "Subnet ID"
    type = string
}

variable "security_group_id" {
    description = "Security Group"
    type = string  
}