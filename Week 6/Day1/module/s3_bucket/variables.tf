variable "account_id" {
    description = "AWS Account ID"
    type = string
}

variable "s3_encryption_algorithm" {
    description = "S3 Encryption Algorithm AES256"
    type = string
    default = "AES256"
}

variable "enable_s3_versioning" {
    description = "Enable Versioning in Log Bucket"
    type = string
    default = "Enabled"
}

variable "log_expiration_days" {
    description = "Days after which logs expire"
    type = number
    default = 90
}

variable "log_noncurrent_expiration_days" {
    description = "Days after which non-current versions expire"
    type = number
    default = 30
}

