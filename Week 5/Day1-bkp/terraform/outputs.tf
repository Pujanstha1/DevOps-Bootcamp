output "elastic_ip" {
    description     = "Elastic IP Public Address"
    value           = aws_eip.lab_eip.public_ip
}

output "private_ip" {
    description     = "EC2 Private IP"
    value           = aws_instance.lab_ec2.private_ip
}

output "public_dns" {
    description     = "EC2 Public DNS"
    value           = aws_eip.lab_eip.public_dns

}