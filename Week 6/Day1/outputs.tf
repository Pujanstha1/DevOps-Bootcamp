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
        public_ip = module.ec2_instance.aws_eip
        log_bucket = aws_s3_bucket.log_bucket.id
        secure_bucket = aws_s3_bucket.secure_bucket.id
    }

}

output "log_bucket_name" {
  value = module.s3_bucket.log_bucket_name
}

output "secure_bucket_name" {
  value = module.s3_bucket.secure_bucket_name
}

output "secure_bucket_arn" {
  value = module.s3_bucket.secure_bucket_arn
}
