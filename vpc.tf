terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 3.27"
    }
  }
}
provider "aws" {
  region = var.region
}

resource "aws_vpc" "vpc_sds" {
  cidr_block = "10.0.0.0/16"
  tags = var.tags
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.vpc_sds.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "private_instance" {
  vpc_id = aws_vpc.vpc_sds.id
  cidr_block = "10.0.2.0/24"
}

resource "aws_subnet" "private_database" {
  vpc_id = aws_vpc.vpc_sds.id
  cidr_block = "10.0.3.0/24"
}

resource "aws_network_interface" "eni_instance" {
  subnet_id = aws_subnet.private_instance.id
  security_groups = [aws_security_group.sg_instance.id]
}

resource "aws_security_group" "sg_instance" {
    name = "sg_connect_db"
}

resource "aws_security_group_rule" "instance_mariadb" {
  type = "ingress"
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  cidr_blocks = [aws_subnet.private_instance.cidr_block]
  security_group_id = aws_security_group.sg_instance.id
}

resource "aws_security_group_rule" "instance_all" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_instance.id
}

resource "aws_key_pair" "sds" {
  key_name = "sds"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFYGg5fSSDVrfjRjsln+VmPRqGWM6nhPtdRHpJDBuece keng2@KengAcethylene-LAPTOP"
}