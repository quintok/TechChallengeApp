module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.64.0"
  name    = "vpc"

  cidr = "10.0.0.0/22"

  azs = ["ap-southeast-2a", "ap-southeast-2b"]

  private_subnets  = ["10.0.0.0/26", "10.0.0.64/26"]
  database_subnets = ["10.0.0.128/26", "10.0.0.192/26"]
  public_subnets   = ["10.0.1.0/26", "10.0.1.64/26"]

  enable_s3_endpoint   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway     = true
  one_nat_gateway_per_az = true
}

resource "aws_security_group" "application-security-group" {
  name   = "application"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "application-to-database" {
  from_port                = module.database.this_rds_cluster_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.application-security-group.id
  to_port                  = module.database.this_rds_cluster_port
  type                     = "egress"
  source_security_group_id = module.database.this_security_group_id
}

resource "aws_security_group_rule" "application-internet-egress" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.application-security-group.id
  to_port           = 443
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}