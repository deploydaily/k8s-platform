output "vpc_id" {
  description = "VPC ID — passed into EKS module"
  value       = aws_vpc.main_vpc.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs — EKS worker nodes live here"
  value       = aws_subnet.private_subnet_one.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs — ALBs and NAT gateway live here"
  value       = aws_subnet.public_subnet_one.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR — useful for security group ingress rules"
  value       = aws_vpc.main_vpc.cidr_block
}