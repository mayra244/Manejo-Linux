# ---------- La urbanización: la VPC
resource "aws_vpc" "pyme" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = "pyme-vpc-tf" }
}