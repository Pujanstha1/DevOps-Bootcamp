# Terraform Variables and Outputs Documentation
## From previous task, commit your Terraform file to GitHub Repo (preferably public). For this task, make a new branch and commit the changes relating to Variable and Outputs usage on another branch.

This document describes the **input variables** and **outputs** used in the Terraform configuration.

---

#### Git Branching

```
git switch -c tux
```
- A new branch named `tux` was created from the main branch.
- All changes related to **Variables** and **Outputs** were committed to this `tux` branch.
- All changes related to Variables and Outputs were committed to this tux branch.
## Input Variables

```
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
```

### `project_name`
- **Description:** Name of the project used for resource tagging
- **Type:** `string`
- **Default:** `terraform-project`

---

### `vpc_cidr`
- **Description:** CIDR block for the VPC
- **Type:** `string`
- **Default:** `10.0.0.0/16`
- **Validation:** Must be a valid IPv4 CIDR block

---

### `subnet_cidr`
- **Description:** CIDR block for the public subnet
- **Type:** `string`
- **Default:** `10.0.1.0/24`
- **Validation:** Must be a valid IPv4 CIDR block

---

### `enable_dns_hostnames`
- **Description:** Enable DNS hostnames in the VPC
- **Type:** `bool`
- **Default:** `true`

---

### `enable_dns_support`
- **Description:** Enable DNS resolution in the VPC
- **Type:** `bool`
- **Default:** `true`

---

### `instance_type`
- **Description:** EC2 instance type
- **Type:** `string`
- **Default:** `t3.micro`

---

### `root_volume_size`
- **Description:** Size of the root EBS volume in GB
- **Type:** `number`
- **Default:** `20`
- **Validation:** Must be between **8 GB** and **100 GB**

---

### `root_volume_type`
- **Description:** Type of root EBS volume
- **Type:** `string`
- **Default:** `gp3`
- **Allowed Values:** `gp2`, `gp3`, `io1`, `io2`

---

### `enable_root_encryption`
- **Description:** Enable encryption for the root EBS volume
- **Type:** `bool`
- **Default:** `true`

---

### `key_name`
- **Description:** Name of the EC2 SSH key pair
- **Type:** `string`
- **Default:** `terraform-key`

---

### `ssh_public_key_path`
- **Description:** Path to the SSH public key file
- **Type:** `string`
- **Default:** `~/.ssh/terraform-key.pub`

---

### `enable_s3_versioning`
- **Description:** Enable or disable S3 bucket versioning
- **Type:** `string`
- **Default:** `Enabled`
- **Allowed Values:** `Enabled`, `Disabled`

---

### `s3_encryption_algorithm`
- **Description:** Server-side encryption algorithm for S3 buckets
- **Type:** `string`
- **Default:** `AES256`

---

## Outputs

```
output "s3_log_bucket_url" {
    description = "S3 Console URL for Log Bucket"
    value = "https://s3.console.aws.amazon.com/s3/buckets/${aws_s3_bucket.log_bucket.id}"
}

output "s3_secure_bucket_url" {
    description = "S3 console URL for secure bucket"
    value       = "https://s3.console.aws.amazon.com/s3/buckets/${aws_s3_bucket.secure_bucket.id}"
}

output "s3_upload_command" {
    description = "Command to upload a file to secure bucket"
    value       = "aws s3 cp <local-file> s3://${aws_s3_bucket.secure_bucket.id}/"
}

output "s3_list_command" {
    description = "Command to list files in secure bucket"
    value       = "aws s3 ls s3://${aws_s3_bucket.secure_bucket.id}/"
}

output "deployment_summary" {
    description = "Summary of Deployed Resources"
    value = {
        project_name = var.project_name
        region = data.aws_region.current.name
        vpc_id = aws_vpc.lab_vpc.id
        instance_id = aws_instance.lab_ec2.id
        instance_type = aws_instance.lab_ec2.instance_type
        public_ip = aws_eip.lab_eip.public_key
        log_bucket = aws_s3_bucket.log_bucket.id
        secure_bucket = aws_s3_bucket.secure_bucket.id
    }

}
```

### `s3_log_bucket_url`
- **Description:** AWS Console URL for the S3 log bucket

---

### `s3_secure_bucket_url`
- **Description:** AWS Console URL for the secure S3 bucket

---

### `s3_upload_command`
- **Description:** AWS CLI command to upload a file to the secure S3 bucket

---

### `s3_list_command`
- **Description:** AWS CLI command to list files in the secure S3 bucket

---

### `deployment_summary`
- **Description:** Summary of deployed resources
- **Contains:**
  - Project name
  - AWS region
  - VPC ID
  - EC2 instance ID
  - EC2 instance type
  - Public IP address
  - Log bucket name
  - Secure bucket name

---
