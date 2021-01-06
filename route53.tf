resource "aws_route53_zone_association" "vpc-assoc" {
  zone_id = var.INTERNAL_DOMAIN_ID
  vpc_id  = aws_vpc.main.id
}
