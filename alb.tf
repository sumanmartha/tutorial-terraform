
resource "aws_alb" "dev_web" {
  name  = "dev-web"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.dev_web_alb.id]
  subnets            = var.vpc_public_subnets

  enable_deletion_protection = false  

  tags = map (
    "Name", "dev_web_alb",
    "Terraform", "true"
  )
}

resource "aws_security_group" "dev_web_alb" {
  name        = "dev_web_alb"
  description = "Allow http and https in inbound and everything in outbound"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id        = var.vpc_id

  tags = map (
    "Name", "dev_web_alb",
    "Terraform", "true"
  )

}

resource "aws_security_group_rule" "dev_web_alb_https" {
  description       = "Allow https traffic."
  to_port           = 443
  from_port         = 443
  protocol          = "tcp"
  cidr_blocks       = ["${local.workstation-external-cidr}"]
  security_group_id = aws_security_group.dev_web_alb.id
  type              = "ingress"

}

resource "aws_security_group_rule" "dev_web_alb_http" {
  description       = "Allow http traffic."
  to_port           = 80
  from_port         = 80
  protocol          = "tcp"
  cidr_blocks       = [local.workstation-external-cidr]
  security_group_id = aws_security_group.dev_web_alb.id
  type              = "ingress"
}

resource "aws_lb_target_group" "dev_web" {
  name     = "dev-web"
  port     =  80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    protocol            = "HTTP"
    path                = "/"
    port                = 80
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
  }

  tags = map (
    "Name", "dev_web_alb",
    "Terraform", "true"
  )
}

resource "aws_alb_listener" "dev_web" {

  load_balancer_arn = aws_alb.dev_web.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_web.arn
  }
}

// Attach the target groups to the instance(s)
resource "aws_lb_target_group_attachment" "dev_web" {
  count            = length(aws_instance.dev_web)
  target_group_arn = element(aws_lb_target_group.dev_web.*.arn, count.index)
  target_id        = aws_instance.dev_web[count.index].id
}