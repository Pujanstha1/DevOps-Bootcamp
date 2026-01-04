# AWS account & region (useful for verification)
output "aws_account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "AWS Account ID"
}

output "aws_region" {
  value       = data.aws_region.current.region
  description = "AWS region in use" 
}

# VPC & networking
output "vpc_id" {
  value       = aws_vpc.lab_vpc.id
  description = "VPC ID"
}

output "subnet_id" {
  value       = aws_subnet.lab_subnet.id
  description = "Public subnet ID"
}

# EC2 instance details
output "ec2_instance_id" {
  value       = aws_instance.lab_ec2.id
  description = "EC2 instance ID"
}

output "ec2_public_ip" {
  value       = aws_eip.lab_eip.public_ip
  description = "Public Elastic IP of the EC2 instance"
}

output "ec2_public_dns" {
  value       = aws_eip.lab_eip.public_dns
  description = "Public DNS name of the EC2 instance"
}

# SSH key reference
output "key_pair_name" {
  value       = aws_key_pair.lab_key.key_name
  description = "EC2 key pair name"
}

# S3 buckets
output "log_bucket_name" {
  value       = aws_s3_bucket.log_bucket.bucket
  description = "S3 log bucket name"
}

output "secure_bucket_name" {
  value       = aws_s3_bucket.secure_bucket.bucket
  description = "Secure S3 bucket name"
}
