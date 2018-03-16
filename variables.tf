### Infrastructure Variables ###

variable "name" {
  type = "string"
  description = "Bastion name"
}

variable "vpc_id" {
  type = "string"
  description = "VPC ID where to deploy the bastion host"
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

variable "bastion_guac_ami" {
  type = "string"
  description = "AMI ID of the Bastion Guacamole instance"
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
  description = "RDS DB name. Only lowercase alphanumeric"
}

variable "db_user" {
  type = "string"
  description = "RDS DB user. Do NOT use root"
}

variable "db_pwd" {
  type = "string"
  description = "RDS DB password"
}

variable "duo_api_hostname" {
  type = "string"
  description = "DUO API hostname"
  default = "------------"
}

variable "duo_integration_key" {
  type = "string"
  description = "DUO Integration Key"
  default = "------------"
}

variable "duo_secret_key" {
  type = "string"
  description = "DUO Secret Key"
  default = "------------"
}

variable "duo_application_key" {
  type = "string"
  description = "DUO App key - random 40 digit number, not provided by duo; generate it yourself, e.g. with pwgen 40 1"
  default = "-----------"
}

variable "admin_username" {
  type = "string"
  description = "Web Admin username. If duo is enabled, use valid DUO account ID; usually AD username"
}

variable "admin_password" {
  type = "string"
  description = "Admin password"
}

variable "ssh_port" {
  type = "string"
  description = "SSH port. Do NOT use default 22"
}

variable "subnet_pub_ids" {
  type = "string"
  description = "Public Subnets IDs, a string with IDs divided by comma"
}

variable "subnet_priv_ids" {
  type = "string"
  description = "Private Subnets IDs, a string with IDs divided by comma"
}


variable "ami_instance_type" {
  description = "bastion_guacamole instance type"
  default = "t2.medium"
}

variable "keypair" {
  type = "string"
  description = "Keypair used on the linux instance"
}

variable "asg_number_of_instances" {
  type = "string"
  description = "bastion_guacamole number of instances in asg"
  default = "1"
}

variable "asg_minimum_number_of_instances" {
  type = "string"
  description = "bastion_guacamole min number of instances"
  default = "1"
}


variable "ssl_cert" {
  type = "string"
  description = "ELB ssl cert"
}


variable "duo_enabled" {
  description = "describe your variable"
  default = false
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