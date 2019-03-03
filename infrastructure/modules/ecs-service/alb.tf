#
# ALB
#
resource "aws_alb" "main" {
  name            = "${var.service_name}-alb-ecs"
  subnets         = ["${var.public_subnets}"]
  security_groups = ["${aws_security_group.lb.id}"]
}

resource "aws_alb_target_group" "main" {
  name        = "${var.service_name}-tg"
  port        = "${var.lb_ingress_port}"
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "${var.lb_ingress_port}"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.main.id}"
    type             = "forward"
  }
}

# ALB Security group
resource "aws_security_group" "lb" {
  name        = "${lower(var.service_name)}-ecs-alb"
  description = "Controls access to the ALB"
  vpc_id      = "${var.vpc_id}"

  ingress {
    protocol    = "tcp"
    from_port   = "${var.lb_ingress_port}"
    to_port     = "${var.lb_ingress_port}"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${lower(var.service_name)}-sg-ecs-alb"
  }
}
