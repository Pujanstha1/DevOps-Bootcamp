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