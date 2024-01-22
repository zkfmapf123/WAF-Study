resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  vpc_id      = aws_vpc.main.id
  description = "alb-sg"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "ec2-alb" {
  name               = "ec2-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]

  dynamic "subnet_mapping" {
    for_each = aws_subnet.public

    content {
      subnet_id = subnet_mapping.value.id
    }
  }

  tags = {
    Name = "ec2-alb"
  }
}

resource "aws_lb_target_group" "ec2-tg" {
  name     = "ec2-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    port     = 80
    protocol = "HTTP"
    matcher  = "200-499"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "ec2-listener" {
  load_balancer_arn = aws_lb.ec2-alb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.ec2-tg.id
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "ec2-alb-attach" {
  target_group_arn = aws_lb_target_group.ec2-tg.arn
  target_id        = module.waf-ec2.out.ec2_id
  port             = 80
}

output "v" {
  value = aws_lb.ec2-alb
}
