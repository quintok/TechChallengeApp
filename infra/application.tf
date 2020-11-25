module "ecs" {
  source             = "terraform-aws-modules/ecs/aws"
  version            = "2.5.0"
  name               = "webapp"
  container_insights = true
}

resource "aws_cloudwatch_log_group" "updatedb" {
  name              = "updatedb"
  retention_in_days = 1
}

resource "aws_cloudwatch_log_group" "webapp" {
  name              = "webapp"
  retention_in_days = 1
}

resource "aws_iam_role" "ecs-execution" {
  name_prefix        = "ecs-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs-assume-execution.json
}

data "aws_iam_policy_document" "ecs-execution-secrets" {
  statement {
    actions = ["secretsmanager:GetSecretValue"]
    effect  = "Allow"
    resources = [
      aws_secretsmanager_secret.password.arn
    ]
  }
}

data "aws_iam_policy_document" "ecs-assume-execution" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs-execution-policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs-execution.name
}

resource "aws_iam_role_policy" "ecs-execution-secrets" {
  policy = data.aws_iam_policy_document.ecs-execution-secrets.json
  role   = aws_iam_role.ecs-execution.id
  name   = "secrets"
}

data "template_file" "task-definition-updatedb" {
  template = file("task-definition.tpl")
  vars = {
    container             = var.docker-container
    command               = jsonencode(["updatedb", "-s"])
    database-password-arn = aws_secretsmanager_secret.password.arn
    database-host         = module.database.this_rds_cluster_endpoint
    database-port         = module.database.this_rds_cluster_port
    database-username     = module.database.this_rds_cluster_master_username
    database-name         = module.database.this_rds_cluster_database_name
    log-group             = aws_cloudwatch_log_group.updatedb.name
  }
}

resource "aws_ecs_task_definition" "updatedb" {
  family                   = "updatedb"
  execution_role_arn       = aws_iam_role.ecs-execution.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions    = data.template_file.task-definition-updatedb.rendered
}

resource "aws_ecs_service" "webapp" {
  name             = "webapp"
  cluster          = module.ecs.this_ecs_cluster_id
  task_definition  = aws_ecs_task_definition.webapp.arn
  launch_type      = "FARGATE"
  desired_count    = 1
  platform_version = "1.4.0"
  load_balancer {
    container_name = "webapp"
    container_port = 3000
    target_group_arn = aws_lb_target_group.application.arn
  }
  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.application-security-group.id]
  }
}

data "template_file" "task-definition-service" {
  template = file("task-definition.tpl")
  vars = {
    container = var.docker-container
    command   = jsonencode(["serve"])

    database-password-arn = aws_secretsmanager_secret.password.arn
    database-host         = module.database.this_rds_cluster_endpoint
    database-port         = module.database.this_rds_cluster_port
    database-username     = module.database.this_rds_cluster_master_username
    database-name         = module.database.this_rds_cluster_database_name
    log-group             = aws_cloudwatch_log_group.webapp.name
  }
}

resource "aws_ecs_task_definition" "webapp" {
  family                   = "webapp"
  execution_role_arn       = aws_iam_role.ecs-execution.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions    = data.template_file.task-definition-service.rendered
}