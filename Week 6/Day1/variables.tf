variable "project_name" {
    description = "Describes the name of the Project"
    type = string
    default = "terraform-project"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "s3_encryption_algorithm" {
  description = "S3 encryption algorithm"
  type        = string
  default     = "AES256"
}

variable "enable_s3_versioning" {
  description = "Enable S3 versioning"
  type        = string
  default     = "Enabled"
}

variable "log_expiration_days" {
  type    = number
  default = 90
}

variable "log_noncurrent_expiration_days" {
  type    = number
  default = 30
}
