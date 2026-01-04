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


#Key Pair
resource "aws_key_pair" "lab_key" {
  key_name   = var.key_name
  public_key = file(var.ssh_public_key_path)
}

resource "aws_instance" "lab_ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.lab_key.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

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

  depends_on = [var.igw_id]
}