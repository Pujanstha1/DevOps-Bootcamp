variable "key_name" {
    type = string
    description = "Key for Terraform"
    default = "terraform-key"
}

variable "vpc_name" {
    type = string
    description = "VPC Name"
    default = "LabVPC"
}

variable "igw" {
    type = string
    description = "AWS Internet Gateway"
    default = "LabInternetGateway"
}

variable "" {
  
}