/* This resource uploads the guacamole.properties config file once it has been rendered.
The "etag" md5 is used for tracking changes and upload again if needed.
Note: you might need to do terraform plan / apply twice when changing the config file
(as db info or enabling duo), probably due to a current terraform glitch (0.11) */

resource "aws_s3_bucket_object" "bastion_guac_properties" {
  depends_on  = ["null_resource.generate_guac_prop"]
  bucket = "${module.s3_repl.s3_bucket}"
  key    = "guacamole.properties"
  source = "${data.template_file.guac_prop_file.rendered}"
  etag   = "${md5(file("${data.template_file.guac_prop_file.rendered}"))}"
}