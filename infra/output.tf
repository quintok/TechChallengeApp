output "update-db-command" {
  value = "aws ecs run-task --task-definition updatedb --cluster webapp --network-configuration \"awsvpcConfiguration={subnets=${jsonencode(module.vpc.private_subnets)},securityGroups=[${aws_security_group.application-security-group.id}]}\" --count 1 --launch-type FARGATE --platform-version 1.4.0"
}

output "webapp-address" {
  value = "http://${aws_lb.application-frontend.dns_name}"
}