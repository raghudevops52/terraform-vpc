locals {
  SUBNET_CIDR   = cidrsubnets(var.VPC_CIDR, 3,3,3,3,3,3,3,3)
}