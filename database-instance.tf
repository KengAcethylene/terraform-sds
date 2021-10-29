resource "aws_network_interface" "eni_database" {
    subnet_id = aws_subnet.private_database.id
    security_groups = [ aws_security_group.sg_database.id ]
}

resource "aws_eip" "database_ip" {
  vpc = true
  network_interface = aws_network_interface.eni_database.id
}

resource "aws_nat_gateway" "ngw_sds" {
    allocation_id = aws_eip.database_ip.id
    subnet_id = aws_subnet.private_database.id

    depends_on = [
      aws_internet_gateway.igw_sds
    ]
  
}


resource "aws_route_table" "private_rt_sds" {
  vpc_id = aws_vpc.vpc_sds.id
}

resource "aws_route" "private_route_rule" {
    route_table_id = aws_route_table.private_rt_sds.id
    nat_gateway_id = aws_nat_gateway.ngw_sds.id
    network_interface_id = aws_network_interface.eni_database.id 
}


resource "aws_security_group" "sg_database" {
  name = "sg_database"
}

resource "aws_security_group_rule" "database_in_all" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [aws_subnet.private_database.cidr_block]
  security_group_id = aws_security_group.sg_database.id
}

resource "aws_security_group_rule" "database_SSH" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_database.id
}

resource "aws_security_group_rule" "database_out_all" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [aws_subnet.private_database.cidr_block]
  security_group_id = aws_security_group.sg_database.id
}

resource "aws_instance" "database" {
  ami = var.ami
  instance_type = var.instance_type

  network_interface {
    network_interface_id = aws_network_interface.eni_database.id
    device_index = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.eni_instance.id
    device_index = 1
  }
  key_name = aws_key_pair.sds.key_name

  tags = {"Name" :"database"}
}