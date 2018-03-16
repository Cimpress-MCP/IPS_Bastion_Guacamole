/* This file is only used for the bastion ec2 instance profile,
as it has to assume the role in order to upload the config files
to the s3 bucket*/

resource "aws_iam_role" "s3_role" {
  name               = "${format("%s-role", var.name)}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "bastion_guac_profile" {
  name  = "bastion_guac"
  role = "${aws_iam_role.s3_role.name}"
}
