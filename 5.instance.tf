data "template_file" "nextcloud_user_data" {
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

    network_interface {
      network_interface_id = aws_network_interface.nextcloud_private_eni.id
      device_index = 1
    }

    user_data = data.template_file.nextcloud_user_data.rendered

    tags = {
      "Name" = "nextcloud"
    }
}

data "template_file" "database_user_data" {
  template = file("database_init.yml")
  vars = {
    app = var.app
  }
}

resource "aws_instance" "database" {
    ami = var.ami
    instance_type = var.instance_type
    key_name = aws_key_pair.key.key_name
    
    network_interface {
      network_interface_id = aws_network_interface.database_nat_eni.id
      device_index = 0
    }

    network_interface {
      network_interface_id = aws_network_interface.database_private_eni.id
      device_index = 1
    }

    user_data = data.template_file.database_user_data.rendered

    tags = {
      "Name" = "database"
    }
}
