resource "aws_lb" "this" {
  name                       = "nginx-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = var.public_subnet_ids
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "this" {
  name = "nginx-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id
  target_type = "ip"
  health_check {
    enabled = true
    path = "/"
    port = 80
    protocol = "HTTP"
    healthy_threshold = 3
    unhealthy_threshold = 3
    timeout = 5
    interval = 30
    matcher = "200"
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}