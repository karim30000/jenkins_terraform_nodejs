output "vpc-id" {
  value = aws_vpc.vpc.id
}

output "vpc-cidr" {
  value = aws_vpc.vpc.cidr_block
}

output "private-subnet-ids" {
  value = aws_subnet.private-subnets.*.id
}

output "public-subnet-ids" {
  value = aws_subnet.public-subnets.*.id
}