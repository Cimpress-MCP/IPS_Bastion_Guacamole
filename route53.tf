/* This file creates the Route53 resources,
Setting the hosted_zone (specified in the variable -do not end it with . as it's done here)
and creating the 2 records for the web access (pointing to the Application LB)
and ssh access (pointing to the Elastic LB) */


resource "aws_route53_record" "bastion_guacamole_dns" {
  zone_id = "${data.aws_route53_zone.hosted_zone.zone_id}"
  name    = "${var.name}.${var.route53_hostedzone}"
  type    = "A"

  alias {
    name                   = "${aws_lb.bastion_guac_alb.dns_name}"
    zone_id                = "${aws_lb.bastion_guac_alb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "bastion_guacamole_dns_ssh" {
  zone_id = "${data.aws_route53_zone.hosted_zone.zone_id}"
  name    = "${var.name}-ssh.${var.route53_hostedzone}"
  type    = "A"

  alias {
    name                   = "${aws_elb.bastion_guac_elb_ssh.dns_name}"
    zone_id                = "${aws_elb.bastion_guac_elb_ssh.zone_id}"
    evaluate_target_health = false
  }
}