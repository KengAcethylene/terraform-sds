data "template_file" "nextcloud_user_data" {
  template = file("nextcloud_script.sh")
  vars = {
    database_name = var.database_name
    database_user = var.database_user
    database_pass = var.database_pass
    admin_user = var.admin_user
    admin_pass = var.admin_pass
    PUBLIC_IP = aws_eip.public_ip.public_ip
    BUCKET_NAME = aws_s3_bucket.nextcloud_s3.bucket
    ACCESS_ID = aws_iam_access_key.nextcloud_key.id
    ACCESS_SECRET = aws_iam_access_key.nextcloud_key.secret
    BUCKET_DOMAIN = aws_s3_bucket.nextcloud_s3.bucket_domain_name
    REGION = var.region
  }
}

resource "aws_instance" "nextcloud" {
    ami = var.ami
    instance_type = "t2.micro"
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

    depends_on = [
      aws_s3_bucket.nextcloud_s3,
      aws_instance.database
    ]
}

data "template_file" "database_user_data" {
  template = file("database_script.sh")
  vars = {
    database_user = var.database_user
    database_pass = var.database_pass
    database_name = var.database_name
  }
}

resource "aws_instance" "database" {
    ami = var.ami
    instance_type = "t2.micro"
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
