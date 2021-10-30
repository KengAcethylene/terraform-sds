data "template_file" "user_data" {
  template = file("nextcloud_init.yml")
  vars = {
    app = var.app
  }
}

resource "aws_instance" "nextcloud" {
    ami = var.ami
    instance_type = var.instance_type
    key_name = aws_key_pair.key.key_name
    
    network_interface {
      network_interface_id = aws_network_interface.nextcloud_public_eni.id
      device_index = 0
    }

    user_data = data.template_file.user_data.rendered

    tags = {
      "Name" = "nextcloud"
    }
}