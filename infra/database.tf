module "database" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "2.29.0"
  name    = "database"

  vpc_id                  = module.vpc.vpc_id
  subnets                 = module.vpc.database_subnets
  instance_type           = "db.t3.medium"
  replica_count           = 1
  instance_type_replica   = "db.t3.medium"
  engine                  = "aurora-postgresql"
  engine_version          = "10.7"
  database_name           = "app"
  skip_final_snapshot     = true // this is to avoid naming conflicts should you re-run terraform.
  allowed_security_groups = [aws_security_group.application-security-group.id]
}

resource "aws_secretsmanager_secret" "password" {
  name                    = "password"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "password" {
  secret_id     = aws_secretsmanager_secret.password.id
  secret_string = module.database.this_rds_cluster_master_password
}