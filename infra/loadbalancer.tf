resource "aws_lb" "application-frontend" {
  name               = "application-external"
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.frontend-lb.id]
}

resource "aws_lb_target_group" "application" {
  target_type = "ip"
  protocol    = "HTTP"
  port        = 3000
  vpc_id      = module.vpc.vpc_id

  health_check {
    path = "/healthcheck/"
  }
}

resource "aws_lb_listener" "application" {
  load_balancer_arn = aws_lb.application-frontend.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application.arn
  }
}