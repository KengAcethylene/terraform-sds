resource "aws_network_interface" "eni_public" {
    subnet_id = aws_subnet.public.id
    security_groups = [ aws_security_group.sg_public.id ]
}

resource "aws_eip" "nextcloud_ip" {
  vpc = true
  network_interface = aws_network_interface.eni_public.id
}

resource "aws_internet_gateway" "igw_sds" {
  vpc_id = aws_vpc.vpc_sds.id
}

resource "aws_route_table" "public_rt_sds" {
  vpc_id = aws_vpc.vpc_sds.id
}

resource "aws_route" "public_route_rule" {
    route_table_id = aws_route_table.public_rt_sds.id
    gateway_id = aws_internet_gateway.igw_sds.vpc_id
    network_interface_id = aws_network_interface.eni_public.id
}

resource "aws_security_group" "sg_public" {
  name = "sg_public"
}

resource "aws_security_group_rule" "public_https" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_public.id
}

resource "aws_security_group_rule" "public_http" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_public.id
}

resource "aws_security_group_rule" "public_SSH" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_public.id
}

resource "aws_security_group_rule" "public_all" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_public.id
}

resource "aws_instance" "app" {
  ami = var.ami
  instance_type = var.instance_type

  network_interface {
    network_interface_id = aws_network_interface.eni_public.id
    device_index = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.eni_instance.id
    device_index = 0
  }
  key_name = aws_key_pair.sds.key_name
  
  tags = {"Name" :"app"}
}