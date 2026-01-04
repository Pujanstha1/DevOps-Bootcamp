variable "project_name" {
    description = "Describes the name of the Project"
    type = string
    # default = "terraform-project" 
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