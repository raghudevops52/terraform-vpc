output "VPC_ID" {
  value = aws_vpc.main.id
}

output "VPC_CIDR" {
  value = aws_vpc.main.cidr_block
}

output "PUBLIC_SUBNETS" {
  value = tolist(aws_subnet.public.*.id)
}

output "WEB_SUBNETS" {
  value = [aws_subnet.private.*.id[0], aws_subnet.private.*.id[1] ]
}

output "APP_SUBNETS" {
  value = [ aws_subnet.private.*.id[2], aws_subnet.private.*.id[3] ]
}

output "DB_SUBNETS" {
  value = [ aws_subnet.private.*.id[4], aws_subnet.private.*.id[5] ]
}

output "DEFAULT_VPC_ID" {
  value = var.DEFAULT_VPC_ID
}

output "DEFAULT_VPC_CIDR" {
  value = data.aws_vpc.default.cidr_block
}

output "INTERNAL_DOMAIN_ID" {
  value = var.INTERNAL_DOMAIN_ID
}

output "EXTERNAL_DOMAIN_ID" {
  value = var.EXTERNAL_DOMAIN_ID
}