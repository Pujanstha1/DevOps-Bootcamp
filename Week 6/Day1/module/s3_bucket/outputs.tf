output "log_bucket_name" {
  description = "Log bucket name"
  value       = aws_s3_bucket.log_bucket.bucket
}

output "secure_bucket_name" {
  description = "Secure bucket name"
  value       = aws_s3_bucket.secure_bucket.bucket
}

output "secure_bucket_arn" {
  description = "Secure bucket ARN"
  value       = aws_s3_bucket.secure_bucket.arn
}
