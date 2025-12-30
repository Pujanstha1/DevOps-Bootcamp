terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "6.27.0"
    }
  }
  required_version = ">=1.2"
}

provider "aws" {
    region = "us-east-1"
}

## Networking (VPC, IGW, Subnet, RouteTable)

resource "aws_vpc" "lab_vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true

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
    vpc_id = aws_vpc.lab_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    
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

resource "aws_route" "default_route" {
    route_table_id = aws_route_table.lab_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_igw.id  
}

resource "aws_route_table_association" "lab-rta" {
    subnet_id = aws_subnet.lab_subnet.id   
    route_table_id = aws_route_table.lab_route_table.id
}

# Security Group

resource "aws_security_group" "lab_sg" {
    name = "LabSecurityGroup"
    description = "Allow SSH and HTTP Traffic"
    vpc_id = aws_vpc.lab_vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "LabSecurityGroup"
    }
}


## EC2 Instance + Elastic IP

resource "aws_instance" "lab_EC2" {
    ami = "ami-084568db4383264d4"
    instance_type = "t3.micro"
    key_name = "terraform-key"
    subnet_id = aws_subnet.lab_subnet.id
    vpc_security_group_ids = [aws_security_group.lab_sg.id]

    root_block_device {
      volume_type = "gp2"
      volume_size = 20
      delete_on_termination = true
    }

    disable_api_termination = false

    tags = {
        Name = "MyEC2"
    }
}

resource "aws_eip" "lab_eip" {
    domain = "vpc"
    instance = aws_instance.lab_EC2.id
    
    tags = {
        Name = "LabElasticIP"
    }
}

## Secure S3 Bucket (Main + Log)
resource "aws_s3_bucket" "log_bucket" {
    bucket = "my-lab-log-bucket-unique-name"        # bucket name

    lifecycle {
      prevent_destroy = true
    }
}


resource "aws_s3_bucket" "secure_bucket" {
    bucket = "my-secure-bucket"

    lifecycle {
      prevent_destroy = true
    }
  
}


## S3 Bucket Security Configuration
resource "aws_s3_bucket_versioning" "secure_versioning" {
    bucket = aws_s3_bucket.secure_bucket.id

    versioning_configuration {
      status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "secure_encryption" {
    bucket = aws_s3_bucket.secure_bucket.id

    rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log_encryption" {
    bucket = aws_s3_bucket.log_bucket.id

    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
}

## Block Public Access and Ownership

resource "aws_s3_bucket_public_access_block" "secure_public_access_bucket" {
    bucket = aws_s3_bucket.secure_bucket.id

    block_public_acls = true
    ignore_public_acls = true
    block_public_policy = true    
    restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "secure_ownership" {
    bucket = aws_s3_bucket.secure_bucket.id

    rule {
        object_ownership = "BucketOwnerEnforced"
    }  
}

## Access Logging

resource "aws_s3_bucket_logging" "secure_logging" {
    bucket = aws_s3_bucket.secure_bucket.id
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "access-logs/"
}

## Enforce HTTPS Only (Bucket Policy)

resource "aws_s3_bucket_policy" "https_only" {
    bucket = aws_s3_bucket.secure_bucket.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid = "EnforceTLS"
                Effect = "Deny"
                Principal = "*"
                Action = "s3:*"
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


## Outputs
output "elastic_eip" {
    value = aws_eip.lab_eip.public_ip
}

output "private_ip" {
    value = aws_instance.lab_EC2.private_ip
}

output "public_ip" {
    value = aws_instance.lab_EC2.public_ip
}

output "public_dns" {
    value = aws_instance.lab_EC2.public_dns
}

output "secure_bucket_name" {
    value = aws_s3_bucket.secure_bucket.bucket  
}

output "log_bucket_name" {
    value = aws_s3_bucket.log_bucket.bucket  
}