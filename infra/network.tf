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