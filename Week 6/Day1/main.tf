# PROVIDER CONFIGURATION

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# DATA SOURCES

# Get latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Get available AZs in the region
data "aws_availability_zones" "available" {
  state = "available"
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}


#Key Pair
resource "aws_key_pair" "lab_key" {
  key_name   = "terraform-key"
  public_key = file("~/.ssh/terraform-key.pub")
}


# VPC RESOURCES

resource "aws_vpc" "lab_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "LabVPC"
  }
}

resource "aws_internet_gateway" "lab_igw" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "LabInternetGateway"
  }
}

resource "aws_subnet" "lab_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "LabSubnet"
  }
}

resource "aws_route_table" "lab_route_table" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "LabRouteTable"
  }
}

resource "aws_route" "lab_route" {
  route_table_id         = aws_route_table.lab_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.lab_igw.id
}

resource "aws_route_table_association" "lab_subnet_association" {
  subnet_id      = aws_subnet.lab_subnet.id
  route_table_id = aws_route_table.lab_route_table.id
}


# SECURITY GROUP RESOURCES

resource "aws_security_group" "lab_sg" {
  name        = "LabSecurityGroup"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.lab_vpc.id

  tags = {
    Name = "LabSecurityGroup"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.lab_sg.id
  description       = "SSH from anywhere"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.lab_sg.id
  description       = "HTTP from anywhere"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.lab_sg.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}


# EC2 INSTANCE RESOURCES

resource "aws_instance" "lab_ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.lab_key.key_name
  subnet_id              = aws_subnet.lab_subnet.id
  vpc_security_group_ids = [aws_security_group.lab_sg.id]

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true
  }

  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "stop"

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "<h1>Terraform EC2 Instance - $(hostname)</h1>" > /var/www/html/index.html
              EOF
  

  tags = {
    Name = "MyEC2"
  }
}

resource "aws_eip" "lab_eip" {
  domain   = "vpc"
  instance = aws_instance.lab_ec2.id

  tags = {
    Name = "LabElasticIP"
  }

  depends_on = [aws_internet_gateway.lab_igw]
}

# S3 BUCKET RESOURCES - LOG BUCKET

resource "aws_s3_bucket" "log_bucket" {
  bucket = "terraform-lab-logs-${data.aws_caller_identity.current.account_id}-${formatdate("YYYYMMDD", timestamp())}"

  tags = {
    Name        = "LogBucket"
    Description = "S3 access logs bucket"
  }

  lifecycle {
    ignore_changes = [bucket]
  }
}

resource "aws_s3_bucket_ownership_controls" "log_bucket_ownership" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "log_bucket_acl" {
  bucket = aws_s3_bucket.log_bucket.id
  acl    = "log-delivery-write"

  depends_on = [aws_s3_bucket_ownership_controls.log_bucket_ownership]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket_encryption" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "log_bucket_versioning" {
  bucket = aws_s3_bucket.log_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "log_bucket_public_access" {
  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "log_bucket_lifecycle" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    id     = "expire-old-logs"
    status = "Enabled"

    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# S3 BUCKET RESOURCES - MAIN SECURE BUCKET

resource "aws_s3_bucket" "secure_bucket" {
  bucket = "terraform-lab-secure-${data.aws_caller_identity.current.account_id}-${formatdate("YYYYMMDD", timestamp())}"

  tags = {
    Name        = "SecureBucket"
    Description = "Main secure S3 bucket with encryption and versioning"
  }

  lifecycle {
    ignore_changes = [bucket]
  }
}

resource "aws_s3_bucket_versioning" "secure_bucket_versioning" {
  bucket = aws_s3_bucket.secure_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "secure_bucket_encryption" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "secure_bucket_public_access" {
  bucket = aws_s3_bucket.secure_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "secure_bucket_ownership" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_logging" "secure_bucket_logging" {
  bucket = aws_s3_bucket.secure_bucket.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "access-logs/"

  depends_on = [aws_s3_bucket_acl.log_bucket_acl]
}

resource "aws_s3_bucket_policy" "enforce_https" {
  bucket = aws_s3_bucket.secure_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.secure_bucket.arn,
          "${aws_s3_bucket.secure_bucket.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# OUTPUTS

output "deployment_summary" {
  description = "Deployment summary"
  value = {
    region          = data.aws_region.current.region
    account_id      = data.aws_caller_identity.current.account_id
    deployment_time = timestamp()
  }
}

output "ec2_details" {
  description = "EC2 instance details"
  value = {
    instance_id       = aws_instance.lab_ec2.id
    instance_type     = aws_instance.lab_ec2.instance_type
    ami_id            = aws_instance.lab_ec2.ami
    ami_name          = data.aws_ami.ubuntu.name
    availability_zone = aws_instance.lab_ec2.availability_zone
    private_ip        = aws_instance.lab_ec2.private_ip
    public_ip         = aws_instance.lab_ec2.public_ip
    elastic_ip        = aws_eip.lab_eip.public_ip
    public_dns        = aws_instance.lab_ec2.public_dns
    ssh_command       = "ssh -i ~/.ssh/my-terraform-key.pem ubuntu@${aws_eip.lab_eip.public_ip}"
    http_url          = "http://${aws_eip.lab_eip.public_ip}"
  }
}

output "vpc_details" {
  description = "VPC and networking details"
  value = {
    vpc_id              = aws_vpc.lab_vpc.id
    vpc_cidr            = aws_vpc.lab_vpc.cidr_block
    subnet_id           = aws_subnet.lab_subnet.id
    subnet_cidr         = aws_subnet.lab_subnet.cidr_block
    internet_gateway_id = aws_internet_gateway.lab_igw.id
    route_table_id      = aws_route_table.lab_route_table.id
    security_group_id   = aws_security_group.lab_sg.id
  }
}

output "s3_details" {
  description = "S3 bucket details"
  value = {
    secure_bucket_name   = aws_s3_bucket.secure_bucket.id
    secure_bucket_arn    = aws_s3_bucket.secure_bucket.arn
    secure_bucket_region = aws_s3_bucket.secure_bucket.region
    log_bucket_name      = aws_s3_bucket.log_bucket.id
    log_bucket_arn       = aws_s3_bucket.log_bucket.arn
    upload_test_command  = "echo 'test' | aws s3 cp - s3://${aws_s3_bucket.secure_bucket.id}/test.txt"
    list_bucket_command  = "aws s3 ls s3://${aws_s3_bucket.secure_bucket.id}/"
  }
}

output "validation_commands" {
  description = "Commands to validate the deployment"
  value       = <<-EOT
    # Validate EC2 instance
    curl http://${aws_eip.lab_eip.public_ip}
    
    # SSH to EC2
    ssh -i ~/.ssh/my-terraform-key.pem ubuntu@${aws_eip.lab_eip.public_ip}
    
    # Test S3 upload
    echo "terraform test" > test.txt
    aws s3 cp test.txt s3://${aws_s3_bucket.secure_bucket.id}/test.txt
    aws s3 ls s3://${aws_s3_bucket.secure_bucket.id}/
    
    # Verify HTTPS enforcement (should fail)
    aws s3api put-object --bucket ${aws_s3_bucket.secure_bucket.id} --key test2.txt --body test.txt --no-sign-request
    
    # Check logs bucket
    aws s3 ls s3://${aws_s3_bucket.log_bucket.id}/access-logs/
  EOT
}

output "state_management_info" {
  description = "Terraform state management information"
  value = {
    state_location      = "Local: terraform.tfstate (default)"
    state_backup        = "Local: terraform.tfstate.backup"
    remote_backend_info = "Configure S3 backend in terraform block to enable remote state"
    state_commands = {
      list_resources = "terraform state list"
      show_resource  = "terraform state show aws_instance.lab_ec2"
      pull_state     = "terraform state pull > state.json"
      refresh_state  = "terraform refresh"
    }
  }
}

output "cleanup_command" {
  description = "Command to destroy all resources"
  value       = "terraform destroy -auto-approve"
}