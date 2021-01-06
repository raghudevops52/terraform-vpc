data "aws_caller_identity" "current" {}

data "aws_vpc" "default" {
  id = var.DEFAULT_VPC_ID
}

data "aws_route_tables" "rts" {
  vpc_id = var.DEFAULT_VPC_ID
}
