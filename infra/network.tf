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

resource "aws_security_group" "frontend-lb" {
  name   = "frontend-lb"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "frontend-to-application" {
  security_group_id        = aws_security_group.frontend-lb.id
  from_port                = 3000
  protocol                 = "tcp"
  to_port                  = 3000
  type                     = "egress"
  source_security_group_id = aws_security_group.application-security-group.id
}

resource "aws_security_group_rule" "application-from-frontend" {
  security_group_id        = aws_security_group.application-security-group.id
  from_port                = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.frontend-lb.id
  to_port                  = 3000
  type                     = "ingress"
}

resource "aws_security_group_rule" "frontend-to-external" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.frontend-lb.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}