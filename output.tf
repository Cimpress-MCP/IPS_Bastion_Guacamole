# Output file

output "1_Route_53" {
  value = ["${aws_route53_record.bastion_guacamole_dns.fqdn}"]
}

output "2_Elastic_Load_Balancer_SSH" {
  value = ["${aws_elb.bastion_guac_elb_ssh.dns_name}","${aws_elb.bastion_guac_elb_ssh.instances}"]
}

output "3_Application_Load_Balancer_Web" {
  value = ["${aws_lb.bastion_guac_alb.dns_name}"]
}

output "4_ELB_SSH_Security_Group" {
  value = ["${aws_security_group.bastion_guac_elb_ssh_sg.id}","${aws_security_group.bastion_guac_elb_ssh_sg.name}","${aws_security_group.bastion_guac_elb_ssh_sg.ingress}","${aws_security_group.bastion_guac_elb_ssh_sg.egress}"]
}

output "5_S3_Buckets_Confs-ALB_Logs-ELB_Logs" {
  value = ["${module.s3_repl.s3_bucket}","${module.s3_alb_web.bucket_name}","${module.s3_elb_ssh.bucket_name}"]
}

output "6_Launch_Configuration" {
  value = ["${aws_launch_configuration.bastion_guac_asg_lc.name}"]
}

output "7_AutoScaling_Group" {
  value = ["${aws_autoscaling_group.bastion_guac_asg.name}","${aws_autoscaling_group.bastion_guac_asg.desired_capacity}","${aws_autoscaling_group.bastion_guac_asg.load_balancers}","${aws_autoscaling_group.bastion_guac_asg.target_group_arns}"]
}

output "8_Instance_Security_Group" {
  value = ["${aws_security_group.bastion_guac_instance_sg.id}","${aws_security_group.bastion_guac_instance_sg.ingress}","${aws_security_group.bastion_guac_instance_sg.egress}"]
}

output "9_RDS" {
  value = ["${module.rds.rds_endpoint}"]
}