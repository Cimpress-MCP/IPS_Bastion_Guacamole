/* This null_resource is a trick to generate the guacamole.properties file
specified in the template above; the provisioner will check the var.duo_enabled, and if
it is true then it will render the full file, otherwise the no_duo.tpl one */

resource "null_resource" "generate_guac_prop" {
    triggers = {
        trigger_object = "${data.template_file.guac_prop.rendered}"
    }

  provisioner "local-exec" {
    command = "${format("cat <<\"EOF\" > \"%s\"\n%s\nEOF", data.template_file.guac_prop_file.rendered, var.duo_enabled ? data.template_file.guac_prop.rendered : data.template_file.guac_prop_no_duo.rendered)}"
  }
}

