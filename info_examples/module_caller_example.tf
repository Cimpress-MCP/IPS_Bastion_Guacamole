terraform {
  backend "s3" {
    # must run: $ terraform init -backend-config 'key=bastion_guac.tfstate'
    bucket = "terraform-tfstate-files" #or any other bucket where to store .tfstate files
    region = "eu-west-1" 
  }
}

provider "aws" {
  region = "eu-west-1"
  version = "~> 1.5"
}

module "bastion-guac" {
  source = "git::https://cimpress.githost.io/ips/terraform_modules/bastion-guac.git"
  name = "${var.name}"
  region = "${var.region}"
  vpc_id = "${data.aws_vpc.vpc_id.id}" #We find the VPC ID with the data filter below, but can be passed as a normal string.
  bastion_guac_ami = "${data.aws_ami.bastion_guac_ami.id}" #We find the AMI with the data filter below, but can be passed as a normal string.
  route53_hostedzone = "${var.route53_hostedzone}"
  squad = "${var.squad}"
  project = "${var.project}"
  route53_hostedzone = "${var.route53_hostedzone}"
  ssh_port = "${var.ssh_port}"
  rds_instance = "${var.rds_instance}"
  db_name = "${var.db_name}"
  db_user = "${var.db_user}"
  db_pwd = "${var.db_pwd}"
  duo_enabled = false #If you want to enable duo, set this to true un-comment the section below and the variables further down.
  /*
  duo_api_hostname = "${var.duo_api_hostname}"
  duo_integration_key = "${var.duo_integration_key}"
  duo_secret_key = "${var.duo_secret_key}"
  duo_application_key = "${var.duo_application_key}"
  */
  subnet_pub_ids = "${join(",", data.aws_subnet_ids.public.ids)}" #We find the Subnet IDs with the data filters below, but can be passed as a normal comma-separated string.
  subnet_priv_ids = "${join(",", data.aws_subnet_ids.private.ids)}"
  keypair = "${var.keypair}"
  ssl_cert = "${var.ssl_cert}"
  admin_username = "${var.admin_username}" #Web interface admin account. If duo is enabled, use a valid DUO user id
  admin_password = "${var.admin_password}"
  # These last variables are for the WAF protections to enable.
  sqlinjection = "${var.sqlinjection}"
  xss = "${var.xss}"
  httpflood = "${var.httpflood}"
  scansprobe = "${var.scansprobe}"
  reputationlists = "${var.reputationlists}"
  badbot = "${var.badbot}"
  httprequeststhreshold = "${var.httprequeststhreshold}"
  scansprobeserrorthreshold = "${var.scansprobeserrorthreshold}"
  wafblockperiod = "${var.wafblockperiod}"
}

/* We find the VPC ID via this data source,
but can also be passed directly as a string */

data "aws_vpc" "vpc_id" {
    filter {
      name   = "tag-key"
      values = ["Name"]
    }

    filter {
      name   = "tag-value"
      values = ["Your_VPC_Name"]
    }
  }

/* We find the Subnets ID via these 2 data sources with the "Env" tags
set to public/private, but can also be passed directly as a comma-separated string */

data "aws_subnet_ids" "public" {
  vpc_id = "${data.aws_vpc.vpc_id.id}"
  tags {
    Env = "public"
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = "${data.aws_vpc.vpc_id.id}"
  tags {
    Env = "private"
  }
}


/* We find the AMI ID via this data source with specific tags (Service:guacamole and latestAmi:true),
but can also be passed as a single string or in any other way */

data "aws_ami" "bastion_guac_ami" {
  most_recent = true

    filter {
      name   = "tag-key"
      values = ["Service"]
    }

    filter {
      name   = "tag-value"
      values = ["guacamole"]
    }

    filter {
      name   = "tag-key"
      values = ["latestAmi"]
    }

    filter {
      name   = "tag-value"
      values = ["true"]
    }
}

# Infrastructure Variables; put in a separate variables.tf file
# And read the descriptions for further details

variable "name" {
  type = "string"
  description = "Bastion name"
}

data "aws_availability_zones" "available" {
  state = "available"
}


variable "region" {
  type = "string"
  description = "AWS Region"
}

variable "squad" {
  type = "string"
  description = "Owner Squad"
}

variable "project" {
  type = "string"
  description = "Project Name"
}

variable "route53_hostedzone" {
  type = "string"
  description = "The name of your Route53 Hosted Zone. Do NOT end it with . "
}

variable "ssh_port" {
  type = "string"
  description = "SSH port. Do NOT use default 22"
}

variable "rds_instance" {
  type = "string"
  description = "RDS instance type"
  default = "db.t2.small"
}

variable "rds_engine_ver" {
  type = "string"
  description = "MySQL version"
  default = "5.6.35"
}

variable "db_name" {
  type = "string"
  description = "RDS DBName - Only alphanumeric lowercase"
}

variable "db_user" {
  type = "string"
  description = "RDS DB user. Do NOT use root"
}

variable "db_pwd" {
  type = "string"
  description = "RDS DB password"
}

# Un-comment all this section if duo_enabled = true 
/* 
variable "duo_api_hostname" {
  type = "string"
  description = "DUO API hostname"
}

variable "duo_integration_key" {
  type = "string"
  description = "DUO Integration Key"
}

variable "duo_secret_key" {
  type = "string"
  description = "DUO Secret Key"
}

variable "duo_application_key" {
  type = "string"
  description = "DUO App key - random 40 digit number, not provided by duo; generate it yourself, e.g. with pwgen 40 1"
}
*/

variable "admin_username" {
  type = "string"
  description = "Web admin (needs to be same as duo account if duo enabled; usually AD username)"
}

variable "admin_password" {
  type = "string"
  description = "Web gui admin password"
}

variable "keypair" {
  type = "string"
  description = "Keypair used on the linux instance"
}

variable "ssl_cert" {
  type = "string"
  description = "ELB ssl cert arn"
}

variable "sqlinjection" {
  type = "string"
  description = "Enable SQL Injection Protection"
  default = "yes"
}

variable "xss" {
  type = "string"
  description = "Enable XSS Protection"
  default = "yes"
}

variable "httpflood" {
  type = "string"
  description = "Enable HTTP Flood Protection"
  default = "yes"
}

variable "scansprobe" {
  type = "string"
  description = "Enable Scans and Probes Protection"
  default = "yes"
}

variable "reputationlists" {
  type = "string"
  description = "Enable blocking requests from 3rd-party reputation lists (spamhaus, torprojects, emergingthreats)"
  default = "yes"
}

variable "badbot" {
  type = "string"
  description = "Enable BadBot and scrapers Protectionm creating an honeypot"
  default = "no"
}

variable "httprequeststhreshold" {
  type = "string"
  description = "If you chose yes for the Activate HTTP Flood Protection parameter, enter the maximum acceptable requests per FIVE-minute period per IP address. Minimum value of 2000. If you chose to deactivate this protection, ignore this parameter."
  default = "2000"
}

variable "scansprobeserrorthreshold" {
  type = "string"
  description = "If you chose yes for the Activate Scanners & Probes Protection parameter, enter the maximum acceptable bad requests per minute per IP. If you chose to deactivate Scanners & Probes protection, ignore this parameter."
  default = "50"
}

variable "wafblockperiod" {
  type = "string"
  description = "If you chose yes for the Activate Scanners & Probes Protection parameters, enter the period (in minutes) to block applicable IP addresses. If you chose to deactivate this protection, ignore this parameter."
  default = "240"
}