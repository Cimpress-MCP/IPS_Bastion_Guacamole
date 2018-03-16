# Create security group for the ssh ELB (allowing only ssh_port inbound)

resource "aws_security_group" "bastion_guac_elb_ssh_sg" {
  name        = "bastion_guac_elb_sg"
  description = "bastion_guacamole ELB/SSH Security Group"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = "${var.ssh_port}"
    to_port     = "${var.ssh_port}"
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
    Name = "${var.name}-elb-ssh-sg"
    Squad = "${var.squad}"
    Project = "${var.project}"
    Environment = "public"
  }
}


# Create the Elastic load balancer for SSH only (as web is behind an ALB with WAF)

resource "aws_elb" "bastion_guac_elb_ssh" {
  depends_on         = ["module.s3_elb_ssh"]
  name               = "${var.name}-elb-ssh"
  subnets            = ["${split(",", var.subnet_pub_ids)}"]

  access_logs {
    bucket        = "${module.s3_elb_ssh.bucket_name}"
    interval      = 60
  }

  listener {
    instance_port      = 22
    instance_protocol  = "tcp"
    lb_port            = "${var.ssh_port}"
    lb_protocol        = "tcp"
  }

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 10
    target              = "TCP:22"
    interval            = 300
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  security_groups = ["${aws_security_group.bastion_guac_elb_ssh_sg.id}"]

  tags {
    Name = "${var.name}-elb-ssh"
    Squad = "${var.squad}"
    Project = "${var.project}"
    Environment = "public"
  }
}

