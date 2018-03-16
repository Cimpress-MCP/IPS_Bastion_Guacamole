data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_route53_zone" "hosted_zone" {
  name         = "${var.route53_hostedzone}."
  private_zone = false
}

/* This template files point to the default guacamole.properties template
with the duo settings; the one below is without */

data "template_file" "guac_prop" {
  template = "${file("${path.module}/data/guacamole.properties.tpl")}"

  vars {
    mysql_hostname = "${module.rds.rds_endpoint}"
    mysql_port = "3306"
    mysql_database = "${var.db_name}"
    mysql_username = "${var.db_user}"
    mysql_password = "${var.db_pwd}"
    duo_api_hostname = "${var.duo_api_hostname}"
    duo_integration_key = "${var.duo_integration_key}"
    duo_secret_key = "${var.duo_secret_key}"
    duo_application_key = "${var.duo_application_key}"
  }
}


data "template_file" "guac_prop_no_duo" {
  template = "${file("${path.module}/data/guacamole.properties_no_duo.tpl")}"

  vars {
    mysql_hostname = "${module.rds.rds_endpoint}"
    mysql_port = "3306"
    mysql_database = "${var.db_name}"
    mysql_username = "${var.db_user}"
    mysql_password = "${var.db_pwd}"
  }
}

/* This template_file points to the actual guacamole.properties file,
which is rendered with the null_resource below */

data "template_file" "guac_prop_file" {
  template = "$${filepath}"

  vars {
    filepath = "${path.module}/data/guacamole.properties"
  }
}

/* This template file points to the user_data template, which will be rendered
into the actual userdata shell script to run at boot-time */
data "template_file" "user_data" {
  template = "${file("${path.module}/data/bastion_guac_userdata.tpl")}"

  vars {
    bucket_name = "${module.s3_repl.s3_bucket}"
    mysql_hostname = "${module.rds.rds_endpoint}"
    db_name = "${var.db_name}"
    db_user = "${var.db_user}"
    db_pwd = "${var.db_pwd}"
    duo_enabled = "${var.duo_enabled}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }
}
