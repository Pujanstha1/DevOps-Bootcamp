# Terraform Configuration Documentation

## Overview
This Terraform configuration creates a complete AWS infrastructure including VPC networking, EC2 instance, and secure S3 buckets with encryption, versioning, and access logging.

---

## Table of Contents
1. [Provider Configuration](#provider-configuration)
2. [Data Sources](#data-sources)
3. [Key Pair Resource](#key-pair-resource)
4. [VPC Resources](#vpc-resources)
5. [Security Group Resources](#security-group-resources)
6. [EC2 Instance Resources](#ec2-instance-resources)
7. [S3 Bucket Resources](#s3-bucket-resources)
8. [Outputs](#outputs)

---

## Provider Configuration

### Terraform Block
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
  }
}
```
**Purpose:** Declares Terraform requirements and provider dependencies.

**What it does:**
- Specifies that this configuration requires the AWS provider
- Pins the AWS provider to version 6.27.0 for consistency
- Ensures all team members use the same provider version

**Why it matters:** Version pinning prevents unexpected breaking changes from provider updates.

---

### AWS Provider
```hcl
provider "aws" {
  region = "us-east-1"
}
```
**Purpose:** Configures the AWS provider with default settings.

**What it does:**
- Sets the default AWS region to `us-east-1` (N. Virginia)
- Establishes connection to AWS API using credentials from:
  - Environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
  - AWS CLI configuration (`~/.aws/credentials`)
  - IAM role (if running on EC2/ECS)

**Resources created:** None (configuration only)

---

## Data Sources

Data sources allow Terraform to fetch information from AWS without creating resources.

### 1. Ubuntu AMI Data Source
```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  
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
```
**Purpose:** Dynamically retrieves the latest Ubuntu 22.04 LTS AMI ID.

**What it does:**
- Searches AWS for Ubuntu 22.04 (Jammy Jellyfish) AMIs
- Owner ID `099720109477` is Canonical (Ubuntu's publisher)
- Filters for HVM virtualization type (modern instances)
- Filters for x86_64 architecture (standard 64-bit)
- Selects the most recent matching AMI

**Why use this:** Instead of hardcoding AMI IDs (which change per region and get outdated), this automatically finds the latest secure Ubuntu image.

**Referenced by:** `aws_instance.lab_ec2.ami`

---

### 2. Availability Zones Data Source
```hcl
data "aws_availability_zones" "available" {
  state = "available"
}
```
**Purpose:** Retrieves list of available availability zones in the current region.

**What it does:**
- Queries AWS for all AZs in us-east-1
- Filters for zones with status "available"
- Returns a list like: `["us-east-1a", "us-east-1b", "us-east-1c", ...]`

**Why use this:** Makes the configuration region-agnostic. If you change regions, this automatically adapts to available zones.

**Referenced by:** `aws_subnet.lab_subnet.availability_zone` uses the first AZ (`[0]`)

---

### 3. AWS Account ID Data Source
```hcl
data "aws_caller_identity" "current" {}
```
**Purpose:** Retrieves current AWS account information.

**What it does:**
- Returns the AWS account ID (e.g., "123456789012")
- Returns the ARN of the caller
- Returns the user ID

**Why use this:** Creates globally unique S3 bucket names by including account ID, preventing naming conflicts.

**Referenced by:** S3 bucket names to ensure global uniqueness

---

### 4. AWS Region Data Source
```hcl
data "aws_region" "current" {}
```
**Purpose:** Retrieves information about the current AWS region.

**What it does:**
- Returns the region name (e.g., "us-east-1")
- Returns the region endpoint
- Returns the region description

**Why use this:** Allows dynamic reference to the current region in outputs and configurations.

**Referenced by:** Output values and availability zone references

---

## Key Pair Resource

### SSH Key Pair
```hcl
resource "aws_key_pair" "lab_key" {
  key_name   = "terraform-key"
  public_key = file("~/.ssh/terraform-key.pub")
}
```
**Purpose:** Creates an AWS EC2 key pair from an existing SSH public key.

**What it does:**
- Reads your local SSH public key from `~/.ssh/terraform-key.pub`
- Uploads it to AWS EC2 as a key pair named "terraform-key"
- Allows SSH access to EC2 instances using the corresponding private key

**Prerequisites:** You must generate the key pair first:
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/terraform-key -C "terraform-lab-key"
```

**Resources created:** 
- AWS EC2 Key Pair: `terraform-key`

**Referenced by:** `aws_instance.lab_ec2.key_name`

---

## VPC Resources

### 1. Virtual Private Cloud (VPC)
```hcl
resource "aws_vpc" "lab_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "LabVPC"
  }
}
```
**Purpose:** Creates an isolated virtual network in AWS.

**What it does:**
- Creates a VPC with CIDR block `10.0.0.0/16` (65,536 IP addresses)
- Enables DNS resolution within the VPC
- Enables DNS hostnames for resources (allows public DNS names)

**IP Range:**
- Network: 10.0.0.0/16
- Usable IPs: 10.0.0.1 - 10.0.255.254
- Total: 65,534 usable addresses

**Resources created:** AWS VPC with ID like `vpc-0a1b2c3d4e5f6g7h8`

**Cost:** Free

---

### 2. Internet Gateway (IGW)
```hcl
resource "aws_internet_gateway" "lab_igw" {
  vpc_id = aws_vpc.lab_vpc.id
  
  tags = {
    Name = "LabInternetGateway"
  }
}
```
**Purpose:** Provides internet connectivity for the VPC.

**What it does:**
- Attaches an Internet Gateway to the VPC
- Enables resources with public IPs to communicate with the internet
- Allows inbound connections from the internet

**Analogy:** The IGW is like the "front door" of your VPC, connecting it to the outside world.

**Resources created:** AWS Internet Gateway with ID like `igw-0a1b2c3d4e5f6g7h8`

**Cost:** Free

---

### 3. Subnet
```hcl
resource "aws_subnet" "lab_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "LabSubnet"
  }
}
```
**Purpose:** Creates a subnet within the VPC for launching resources.

**What it does:**
- Creates a subnet with CIDR `10.0.0.0/24` (256 IP addresses)
- Places subnet in the first available AZ (e.g., us-east-1a)
- Automatically assigns public IPs to instances launched in this subnet

**IP Range:**
- Network: 10.0.0.0/24
- Usable IPs: 10.0.0.4 - 10.0.0.254
- Total: 251 usable addresses (AWS reserves 5 IPs)

**Reserved IPs by AWS:**
- 10.0.0.0: Network address
- 10.0.0.1: VPC router
- 10.0.0.2: DNS server
- 10.0.0.3: Future use
- 10.0.0.255: Broadcast address

**Resources created:** AWS Subnet with ID like `subnet-0a1b2c3d4e5f6g7h8`

**Cost:** Free

---

### 4. Route Table
```hcl
resource "aws_route_table" "lab_route_table" {
  vpc_id = aws_vpc.lab_vpc.id
  
  tags = {
    Name = "LabRouteTable"
  }
}
```
**Purpose:** Creates a route table to control network traffic routing.

**What it does:**
- Creates a custom route table for the VPC
- Will contain rules (routes) that determine where network traffic is directed
- Acts as a "traffic controller" for the subnet

**Resources created:** AWS Route Table with ID like `rtb-0a1b2c3d4e5f6g7h8`

**Cost:** Free

---

### 5. Route (Internet Route)
```hcl
resource "aws_route" "lab_route" {
  route_table_id         = aws_route_table.lab_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.lab_igw.id
}
```
**Purpose:** Creates a route that sends internet-bound traffic to the Internet Gateway.

**What it does:**
- Adds a route to the route table
- Destination `0.0.0.0/0` means "all internet traffic"
- Directs all internet traffic through the Internet Gateway

**Route Table Entry:**
| Destination | Target | Purpose |
|-------------|--------|---------|
| 0.0.0.0/0 | igw-xxx | Internet access |
| 10.0.0.0/16 | local | Internal VPC traffic (implicit) |

**Resources created:** Route entry in the route table

**Cost:** Free

---

### 6. Route Table Association
```hcl
resource "aws_route_table_association" "lab_subnet_association" {
  subnet_id      = aws_subnet.lab_subnet.id
  route_table_id = aws_route_table.lab_route_table.id
}
```
**Purpose:** Associates the route table with the subnet.

**What it does:**
- Links the custom route table to the subnet
- All resources in the subnet now use this route table's routing rules
- Without this, the subnet would use the VPC's default route table

**Analogy:** This is like assigning a specific set of directions to everyone in a neighborhood.

**Resources created:** Route Table Association

**Cost:** Free

---

## Security Group Resources

### 1. Security Group
```hcl
resource "aws_security_group" "lab_sg" {
  name        = "LabSecurityGroup"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.lab_vpc.id
  
  tags = {
    Name = "LabSecurityGroup"
  }
}
```
**Purpose:** Creates a virtual firewall for the EC2 instance.

**What it does:**
- Creates a security group in the VPC
- Acts as a stateful firewall (remembers connections)
- Will contain ingress (inbound) and egress (outbound) rules

**Analogy:** Security groups are like a building's security system, controlling who can enter and exit.

**Resources created:** AWS Security Group with ID like `sg-0a1b2c3d4e5f6g7h8`

**Cost:** Free

---

### 2. SSH Ingress Rule
```hcl
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.lab_sg.id
  description       = "SSH from anywhere"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}
```
**Purpose:** Allows SSH connections to the EC2 instance from anywhere.

**What it does:**
- Opens TCP port 22 (SSH) for inbound connections
- Source `0.0.0.0/0` means "from any IP address on the internet"
- Enables remote terminal access to the EC2 instance

**Security Consideration:** `0.0.0.0/0` allows SSH from anywhere. In production, restrict this to specific IP ranges:
```hcl
cidr_ipv4 = "203.0.113.0/24"  # Your office IP range
```

**Resources created:** Ingress rule in the security group

**Cost:** Free

---

### 3. HTTP Ingress Rule
```hcl
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.lab_sg.id
  description       = "HTTP from anywhere"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}
```
**Purpose:** Allows HTTP web traffic to the EC2 instance from anywhere.

**What it does:**
- Opens TCP port 80 (HTTP) for inbound connections
- Source `0.0.0.0/0` allows public web access
- Enables anyone on the internet to view the web server

**Use Case:** Hosting public websites or web applications.

**Resources created:** Ingress rule in the security group

**Cost:** Free

---

### 4. All Outbound Traffic Rule
```hcl
resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.lab_sg.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
```
**Purpose:** Allows all outbound connections from the EC2 instance.

**What it does:**
- Allows all protocols (`-1` means all)
- Allows connections to any destination (`0.0.0.0/0`)
- Enables the instance to download updates, access APIs, etc.

**Why needed:** EC2 instance needs outbound access to:
- Download package updates (`apt-get update`)
- Install software (`apt-get install nginx`)
- Access external APIs
- Respond to inbound connections (stateful return traffic)

**Resources created:** Egress rule in the security group

**Cost:** Free

---

## EC2 Instance Resources

### 1. EC2 Instance
```hcl
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
```
**Purpose:** Creates an EC2 virtual machine instance.

#### Configuration Breakdown:

**`ami`** - Operating System Image
- Uses the Ubuntu 22.04 AMI dynamically retrieved earlier
- Contains the base operating system and software

**`instance_type = "t3.micro"`** - Instance Size
- 2 vCPUs (virtual CPUs)
- 1 GB RAM
- Burstable performance (can burst above baseline when needed)
- Free tier eligible (750 hours/month for 12 months)

**`key_name`** - SSH Access
- Associates the SSH key pair for remote access
- Allows: `ssh -i ~/.ssh/terraform-key ubuntu@<ip>`

**`subnet_id`** - Network Placement
- Launches instance in the lab subnet
- Instance receives private IP from subnet range (10.0.0.x)
- Automatically gets public IP due to subnet configuration

**`vpc_security_group_ids`** - Firewall Rules
- Attaches the security group (firewall rules)
- Controls inbound/outbound traffic

#### Root Block Device Configuration:

**`volume_type = "gp3"`** - Storage Type
- General Purpose SSD (newest generation)
- Better price/performance than gp2
- 3000 IOPS baseline, 125 MB/s throughput

**`volume_size = 20`** - Storage Size
- 20 GB disk space
- Sufficient for OS, applications, and logs

**`delete_on_termination = true`** - Cleanup Behavior
- Automatically deletes volume when instance is terminated
- Prevents orphaned volumes

**`encrypted = true`** - Security
- Encrypts data at rest using AWS-managed keys
- No additional cost
- Enhances security compliance

#### Instance Behavior:

**`disable_api_termination = false`**
- Allows instance to be terminated via API/Console
- Set to `true` in production to prevent accidental deletion

**`instance_initiated_shutdown_behavior = "stop"`**
- When OS shutdown is initiated, instance stops (doesn't terminate)
- Data is preserved

#### User Data Script:

**Purpose:** Automatically configures the instance on first boot.

**What it does:**
1. `apt-get update` - Updates package lists
2. `apt-get install -y nginx` - Installs Nginx web server
3. `systemctl start nginx` - Starts the web server
4. `systemctl enable nginx` - Enables auto-start on boot
5. Creates custom HTML homepage with hostname

**Result:** Web server is running and accessible at `http://<public-ip>` immediately after instance launches.

**Resources created:** 
- EC2 Instance with ID like `i-0a1b2c3d4e5f6g7h8`
- EBS Volume (20GB gp3)

**Cost:** ~$7.50/month (after free tier) + $1.60/month for storage

---

### 2. Elastic IP
```hcl
resource "aws_eip" "lab_eip" {
  domain   = "vpc"
  instance = aws_instance.lab_ec2.id
  
  tags = {
    Name = "LabElasticIP"
  }
  
  depends_on = [aws_internet_gateway.lab_igw]
}
```
**Purpose:** Allocates a static public IP address and associates it with the EC2 instance.

**What it does:**
- Allocates an Elastic IP from AWS's pool of public IPs
- Associates it with the EC2 instance
- IP remains the same even if instance is stopped and started

**Why needed:**
- EC2 instances get dynamic public IPs that change on stop/start
- Elastic IPs provide a persistent public IP address
- Essential for DNS records, firewall rules, and consistent access

**Without EIP:**
```
Instance start: Public IP = 54.123.45.67
Instance stop
Instance start: Public IP = 52.98.76.54  ← Changed!
```

**With EIP:**
```
Instance start: Public IP = 54.123.45.67
Instance stop
Instance start: Public IP = 54.123.45.67  ← Same!
```

**`depends_on = [aws_internet_gateway.lab_igw]`**
- Ensures IGW exists before allocating EIP
- Prevents errors during resource creation

**Resources created:** Elastic IP with allocation ID like `eipalloc-0a1b2c3d4e5f6g7h8`

**Cost:** 
- Free when attached to a running instance
- ~$0.005/hour (~$3.60/month) when unattached or instance is stopped

---

## S3 Bucket Resources

### Log Bucket Resources

#### 1. S3 Log Bucket
```hcl
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
```
**Purpose:** Creates an S3 bucket to store access logs from the secure bucket.

**What it does:**
- Creates bucket with globally unique name using account ID and date
- Example name: `terraform-lab-logs-123456789012-20241230`
- Stores access logs from the secure bucket

**Bucket Naming:**
- Must be globally unique across all AWS accounts
- `${data.aws_caller_identity.current.account_id}` - Your AWS account ID
- `${formatdate("YYYYMMDD", timestamp())}` - Current date (e.g., 20241230)

**`lifecycle { ignore_changes = [bucket] }`**
- Prevents Terraform from trying to rename bucket on future applies
- Bucket names can't be changed; they must be deleted and recreated
- This keeps the same bucket even if timestamp changes

**Resources created:** S3 bucket

**Cost:** 
- $0.023 per GB/month (Standard storage)
- First 50 GB is free tier

---

#### 2. Log Bucket Ownership Controls
```hcl
resource "aws_s3_bucket_ownership_controls" "log_bucket_ownership" {
  bucket = aws_s3_bucket.log_bucket.id
  
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
```
**Purpose:** Configures ownership of objects written to the bucket.

**What it does:**
- Sets ownership to "BucketOwnerPreferred"
- When S3 service writes logs, bucket owner owns the objects
- Allows bucket owner to manage all logs

**Why needed:** AWS S3 logging service writes objects with its own ownership. This ensures you own the log files.

**Resources created:** Ownership control configuration

**Cost:** Free

---

#### 3. Log Bucket ACL
```hcl
resource "aws_s3_bucket_acl" "log_bucket_acl" {
  bucket = aws_s3_bucket.log_bucket.id
  acl    = "log-delivery-write"
  
  depends_on = [aws_s3_bucket_ownership_controls.log_bucket_ownership]
}
```
**Purpose:** Grants AWS S3 logging service permission to write logs.

**What it does:**
- Applies the "log-delivery-write" ACL
- Allows AWS S3 service to write log files to this bucket
- Required for access logging to work

**`acl = "log-delivery-write"`** - Predefined ACL that grants:
- S3 Log Delivery group: WRITE and READ_ACP permissions
- Bucket owner: FULL_CONTROL

**Resources created:** Bucket ACL configuration

**Cost:** Free

---

#### 4. Log Bucket Encryption
```hcl
resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket_encryption" {
  bucket = aws_s3_bucket.log_bucket.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}
```
**Purpose:** Encrypts all objects stored in the log bucket.

**What it does:**
- Enables AES-256 encryption for all objects
- Objects are automatically encrypted when stored
- Objects are automatically decrypted when retrieved

**`sse_algorithm = "AES256"`**
- Uses AWS S3-managed encryption keys (SSE-S3)
- No additional cost
- AWS handles key management automatically

**`bucket_key_enabled = true`**
- Reduces encryption costs by ~99%
- Uses bucket-level keys instead of object-level keys
- Reduces API calls to AWS KMS

**Resources created:** Encryption configuration

**Cost:** Free (for AES256 encryption)

---

#### 5. Log Bucket Versioning
```hcl
resource "aws_s3_bucket_versioning" "log_bucket_versioning" {
  bucket = aws_s3_bucket.log_bucket.id
  
  versioning_configuration {
    status = "Enabled"
  }
}
```
**Purpose:** Enables versioning for all objects in the log bucket.

**What it does:**
- Keeps multiple versions of each log file
- Protects against accidental deletion or overwriting
- Allows rollback to previous versions

**How versioning works:**
```
Upload log-file.txt (version 1)
Upload log-file.txt (version 2) ← Original still exists
Delete log-file.txt ← Creates delete marker, file still recoverable
```

**Benefits:**
- Audit trail of all changes
- Protection against accidental deletion
- Compliance requirements

**Resources created:** Versioning configuration

**Cost:** Storage cost for each version retained

---

#### 6. Log Bucket Public Access Block
```hcl
resource "aws_s3_bucket_public_access_block" "log_bucket_public_access" {
  bucket = aws_s3_bucket.log_bucket.id
  
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
```
**Purpose:** Prevents any public access to the log bucket.

**What it does:**
- Blocks all forms of public access
- Ensures logs remain private
- Overrides any ACLs or policies that might grant public access

**Settings explained:**

**`block_public_acls = true`**
- Blocks PUT requests with public ACLs
- Prevents making objects publicly readable

**`ignore_public_acls = true`**
- Ignores any existing public ACLs
- Treats all objects as private regardless of ACLs

**`block_public_policy = true`**
- Blocks bucket policies that grant public access
- Prevents accidental public exposure via policies

**`restrict_public_buckets = true`**
- Restricts access to bucket owners and AWS services
- Additional layer of protection

**Resources created:** Public access block configuration

**Cost:** Free

---

#### 7. Log Bucket Lifecycle Configuration
```hcl
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
```
**Purpose:** Automatically deletes old log files to reduce storage costs.

**What it does:**
- Deletes log files after 90 days
- Deletes old versions after 30 days
- Runs automatically daily

**Rules:**

**`expiration { days = 90 }`**
- Current version of objects deleted after 90 days
- Applies to log files created 90+ days ago

**`noncurrent_version_expiration { noncurrent_days = 30 }`**
- Old versions deleted 30 days after becoming non-current
- When a file is updated, old version is deleted after 30 days

**Timeline example:**
```
Day 0:   Upload log-2024-01-01.txt
Day 30:  Upload log-2024-01-01.txt (new version)
         - Old version will be deleted on Day 60
Day 90:  Current version deleted automatically
```

**Resources created:** Lifecycle policy

**Cost:** Free (reduces storage costs)

---

### Secure Bucket Resources

#### 8. S3 Secure Bucket
```hcl
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
```
**Purpose:** Creates the main S3 bucket for storing application data securely.

**What it does:**
- Creates bucket with globally unique name
- Example: `terraform-lab-secure-123456789012-20241230`
- Will be configured with encryption, versioning, and logging

**Use cases:**
- Application data storage
- User uploads
- Backups
- Static website hosting

**Resources created:** S3 bucket

**Cost:** $0.023 per GB/month (Standard storage)

---

#### 9. Secure Bucket Versioning
```hcl
resource "aws_s3_bucket_versioning" "secure_bucket_versioning" {
  bucket = aws_s3_bucket.secure_bucket.id
  
  versioning_configuration {
    status = "Enabled"
  }
}
```
**Purpose:** Enables versioning to protect against accidental deletion or modification.

**What it does:**
- Keeps all versions of every object
- Allows recovery of deleted or overwritten files
- Provides audit trail

**Example workflow:**
```
1. Upload document.pdf (v1)
2. Upload document.pdf (v2) - v1 still available
3. Delete document.pdf - Creates delete marker, v1 and v2 recoverable
4. Restore any version at any time
```

**Resources created:** Versioning configuration

**Cost:** Storage for each version

---

#### 10. Secure Bucket Encryption
```hcl
resource "aws_s3_bucket_server_side_encryption_configuration" "secure_bucket_encryption" {
  bucket = aws_s3_bucket.secure_bucket.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}
```
**Purpose:** Encrypts all data at rest in the secure bucket.

**What it does:**
- Automatically encrypts files when uploaded
- Automatically decrypts when downloaded
- Uses AES-256 encryption algorithm

**Security benefits:**
- Protects data from unauthorized access to physical storage
- Meets compliance requirements (HIPAA, PCI-DSS, etc.)
- No performance impact

**Resources created:** Encryption configuration

**Cost:** Free

---

#### 11. Secure Bucket Public Access Block
```hcl
resource "aws_s3_bucket_public_access_block" "secure_bucket_public_access" {
  bucket = aws_s3_bucket.secure_bucket.id
  
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
```
**Purpose:** Prevents any public access to the secure bucket.

**What it does:**
- Blocks all public access mechanisms
- Ensures data remains private
- Prevents accidental data exposure

**All four settings set to `true`:**
- Maximum