## VPC
resource "aws_vpc" "lab_vpc" {
    cidr_block              = "10.0.0.0/16"
    enable_dns_support      = true
    enable_dns_hostnames    = true

    tags = {
        Name = "LabVPC"
    }
}

## Internet Gateway
resource "aws_internet_gateway" "lab_igw" {
    vpc_id = aws_vpc.lab_vpc.id

    tags = {
        Name = "LabInternetGateway"
    }
}

## Subnet
resource "aws_subnet" "lab_subnet" {
    vpc_id              = aws_vpc.lab_vpc.id
    cidr_block          = "10.0.1.0/24"
    availability_zone   = "us-east-1a"

    tags = {
        Name = "LabSubnet"
    }
}

## RouteTable
resource "aws_route_table" "lab_rt" {
    vpc_id = aws_vpc.lab_vpc.id

    tags = {
        Name = "LabRouteTable"
    }
}

## Internet Route
resource "aws_route" "internet_route" {
    route_table_id          = aws_route_table.lab_rt.id
    destination_cidr_block  = "0.0.0.0/0"
    gateway_id              = aws_internet_gateway.lab_igw.id
}

## RouteTable Association
resource "aws_route_table_association" "subnet_assoc" {
    subnet_id       = aws_subnet.lab_subnet.id
    route_table_id  = aws_route_table.lab_rt.id
}

## Security Group
resource "aws_security_group" "lab_sg" {
    name            = "LabSecurityGroup"
    description     = "Allow SSH and HTTP"
    vpc_id          = aws_vpc.lab_vpc.id

    ingress {
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "LabSecurityGroup"
    }
}


## EC2 Instance
resource "aws_instance" "lab_ec2" {
    ami                         = "ami-084568db4383264d4" # Ubuntu 24.04 (us-east-1)
    instance_type               = "t3.micro"
    key_name                    = var.key_pair_name

    subnet_id                   = aws_subnet.lab_subnet.id
    vpc_security_group_ids      = [aws_security_group.lab_sg.id]

    root_block_device {
        volume_type             = "gp2"
        volume_size             = 20
        delete_on_termination   = true
    }

    tags = {
        Name = "MyEC2"
    }
}

## Elastic IP
resource "aws_eip" "lab_eip" {
    instance = aws_instance.lab_ec2.id
    domain   = "vpc"

    tags = {
        Name = "LabElasticIP"
    }
} 
