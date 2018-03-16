# Create the Application Load Balancer security group

resource "aws_security_group" "bastion_guac_alb_sg" {
  name        = "bastion_guac_alb_sg"
  description = "bastion_guacamole ALB Security Group"
  vpc_id      = "${var.vpc_id}"


  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
    tags {
    Name = "${var.name}-alb-sg"
    Squad = "${var.squad}"
    Project = "${var.project}"
    Environment = "public"
  }
}


# Create The Application Load Balancer

resource "aws_lb" "bastion_guac_alb" {
  depends_on    = ["module.s3_alb_web"]
  name               = "${var.name}-alb"
  load_balancer_type  = "application"
  internal          = false
  subnets            = ["${split(",", var.subnet_pub_ids)}"]
  security_groups = ["${aws_security_group.bastion_guac_alb_sg.id}"]

  access_logs {
    bucket        = "${module.s3_alb_web.bucket_name}"
    enabled = true
  }

  tags {
    Name = "${var.name}-alb"
    Squad = "${var.squad}"
    Project = "${var.project}"
    Environment = "public"
  }
}

# Create the target group for the ALB
resource "aws_lb_target_group" "bastion_target_group" {
  name     = "${var.name}-target-group"
  port     = "8080"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path = "/"
    interval            = 300
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 10
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create the lb listener, pointing to the ALB and forwarding to the target group
resource "aws_lb_listener" "bastion_listener_https" {
  load_balancer_arn = "${aws_lb.bastion_guac_alb.arn}"
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = "${var.ssl_cert}"

  default_action {
    target_group_arn = "${aws_lb_target_group.bastion_target_group.arn}"
    type = "forward"
  }
}