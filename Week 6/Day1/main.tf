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
  key_name   = var.key_name
  public_key = file(var.ssh_public_key_path)
}


# VPC RESOURCES

resource "aws_vpc" "lab_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name = "${var.project_name}-LabVPC"
  }
}

resource "aws_internet_gateway" "lab_igw" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "${var.project_name}-LabInternetGateway"
  }
}

resource "aws_subnet" "lab_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-LabSubnet"
  }
}

resource "aws_route_table" "lab_route_table" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "${var.project_name}-LabRouteTable"
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
    Name = "${var.project_name}-LabSecurityGroup"
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
  instance_type          = var.instance_type
  key_name               = aws_key_pair.lab_key.key_name
  subnet_id              = aws_subnet.lab_subnet.id
  vpc_security_group_ids = [aws_security_group.lab_sg.id]

  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    delete_on_termination = true
    encrypted             = var.enable_root_encryption
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
    Name = "${var.project_name}-MyEC2"
  }
}

resource "aws_eip" "lab_eip" {
  domain   = "vpc"
  instance = aws_instance.lab_ec2.id

  tags = {
    Name = "${var.project_name}-LabElasticIP"
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
      sse_algorithm = var.s3_encryption_algorithm
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "log_bucket_versioning" {
  bucket = aws_s3_bucket.log_bucket.id

  versioning_configuration {
    status = var.enable_s3_versioning
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

