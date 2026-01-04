output "subnet_id" {
    description = "Subnet ID"
    value = aws_subnet.lab_subnet.id
}

output "security_group_id" {
    description = "Security Group ID"
    value = aws_security_group.lab_sg.id  
}

output "igw" {
    value = aws_internet_gateway.lab_igw.id
}