terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 3.27"
    }
  }
}

provider "aws" {
  profile = "default"
  region = var.region
}

resource "aws_security_group" "db" {
  name = "db"
}

resource "aws_security_group_rule" "https" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.db.id
}

resource "aws_security_group_rule" "ssh" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.db.id
}

resource "aws_key_pair" "sds" {
  
  key_name = "sds"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPOZhrLTc0gO8vpyPH++r4sEDeCji7N1y0D5M+J/+AXQ keng@Keng-Acethylene"
}

resource "aws_instance" "mariadb" {

  ami = var.ami
  key_name = aws_key_pair.sds.key_name
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.db.id]
  tags = var.tags
  connection {
    type = "ssh"
    host = self.public_ip
    user = "ubuntu"
    private_key = file("C:\\Users\\Keng\\.ssh\\sds.pem")
  }
  provisioner "remote-exec" {
    inline = [
      "touch hello.txt",
      "echo helloworld remote provisioner >> hello.txt",
    ]
  }
}