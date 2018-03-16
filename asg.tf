/* Create the bastion instance security group, allowing only inbound connections 
from the respective LoadBalancers SecurityGroups on 8080 and ssh */

resource "aws_security_group" "bastion_guac_instance_sg" {
  name = "bastion_guac_instance_sg"
  description = "Bastion Guacamole Security Group"
  vpc_id = "${var.vpc_id}"


  ingress {
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  security_groups = ["${aws_security_group.bastion_guac_alb_sg.id}"]
  }

  ingress {
  from_port = 22
  to_port = 22
  protocol = "tcp"
  security_groups = ["${aws_security_group.bastion_guac_elb_ssh_sg.id}"]
  }

  egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
  Name = "${var.name}-instance-sg"
  Squad = "${var.squad}"
  Project = "${var.project}"
  Environment = "private"
  }
}



# Create the launch configuration

resource "aws_launch_configuration" "bastion_guac_asg_lc" {
  name_prefix   = "${var.name}-lc"
  image_id      = "${var.bastion_guac_ami}"
  instance_type = "${var.ami_instance_type}"
  key_name      = "${var.keypair}"
  security_groups = ["${aws_security_group.bastion_guac_instance_sg.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.bastion_guac_profile.id}"
  user_data     = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

# Create the autoscaling group

resource "aws_autoscaling_group" "bastion_guac_asg" {
  depends_on                = ["module.rds"]
  availability_zones        = ["${data.aws_availability_zones.available.names}"]
  name                      = "${var.name}"
  max_size = "${var.asg_number_of_instances}"
  min_size = "${var.asg_minimum_number_of_instances}"
  desired_capacity = "${var.asg_number_of_instances}"
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.bastion_guac_asg_lc.name}"
  load_balancers            = ["${aws_elb.bastion_guac_elb_ssh.name}"]
  target_group_arns         = ["${aws_lb_target_group.bastion_target_group.arn}"]

  lifecycle {
    create_before_destroy = true
  }

vpc_zone_identifier = ["${split(",", var.subnet_priv_ids)}"]


  tag {
    key   = "Name",
    value = "${var.name}",
    propagate_at_launch = true
  }

  tag {
    key   = "Project",
    value = "${var.project}",
    propagate_at_launch = true
  }

  tag {
    key   = "Squad",
    value = "${var.squad}",
    propagate_at_launch = true
  }

  tag {
    key   = "Environment",
    value = "private",
    propagate_at_launch = true
  }

  tag {
    key   = "Inspector",
    value = "${var.name}",
    propagate_at_launch = true
  }
}