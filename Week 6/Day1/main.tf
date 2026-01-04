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

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# # DATA SOURCES
# module "tf_vpc" {
#   source = "./module/vpc"
#   project_name = var.project_name 
# }

# VPC RESOURCES
module "vpc" {
  source = "./module/vpc"
  project_name = var.project_name
}

# EC2 INSTANCE RESOURCES
module "ec2_instance" {
  source = "./module/ec2"
  project_name = var.project_name
  security_group_id = module.vpc.security_group_id
  subnet_id = module.vpc.subnet_id 
  igw_id = module.vpc.igw
}

# S3 BUCKET RESOURCES

module "s3_bucket" {
  source = "./modules/s3_bucket"

  account_id                    = data.aws_caller_identity.current.account_id
  s3_encryption_algorithm        = var.s3_encryption_algorithm
  enable_s3_versioning           = var.enable_s3_versioning
  log_expiration_days            = var.log_expiration_days
  log_noncurrent_expiration_days = var.log_noncurrent_expiration_days
}