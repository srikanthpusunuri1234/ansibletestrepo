# Security group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "${var.name}-alb-security-group"
  description = "Allows HTTP and HTTPS traffic to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-alb-security-group"
  }
}

# Application Load Balancer
resource "aws_lb" "this" {
  name               = "example-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = [aws_security_group.alb_sg.id] # ALB SG attached
}

resource "aws_lb_target_group" "this1" {
  name     = "${var.name}-tg1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "this2" {
  name     = "${var.name}-tg2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}



resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this1.arn
  }
}


#resource "aws_lb_listener" "https" {
#  load_balancer_arn = aws_lb.this.arn   # same ALB as http
#  port              = 443
#  protocol          = "HTTPS"
#  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"  # pick as needed
#  certificate_arn   = var.acm_certificate_arn         # ACM cert for domain
#
#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.this1.arn   # same TG unless different needed
#  }
#}


# Route 53 record that points domain to ELB
# resource "aws_route53_record" "app_record" {
#   zone_id = "Z1234567890ABC"   # Replace with your hosted zone ID
#   name    = "app.example.com"  # Subdomain you want
#   type    = "A"
#
#   alias {
#     name                   = aws_lb.this.dns_name
#     zone_id                = aws_lb.app_lb.zone_id
#     evaluate_target_health = true
#   }
# }

# Host-based rule for app2
resource "aws_lb_listener_rule" "app2_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 1  # must be unique among rules

  action {
    type             = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.this1.arn
        weight = 50 # Old version receives 80% of traffic
      }
      target_group {
        arn    = aws_lb_target_group.this2.arn
        weight = 50 # New version receives 20% of traffic (the "canary")
      }
    }  
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}


output "alb_dns" {
  value = aws_lb.this.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.this1.arn
}

output "target_group2_arn" {
  value = aws_lb_target_group.this2.arn
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}
