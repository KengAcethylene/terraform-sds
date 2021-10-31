resource "aws_network_interface" "nextcloud_public_eni" {
    subnet_id = aws_subnet.public_subnet.id
    security_groups = [ aws_security_group.public_sg_group.id ]
}

resource "aws_network_interface" "nextcloud_private_eni" {
    subnet_id = aws_subnet.private_instance.id
    security_groups = [ aws_security_group.private_instance.id ]
    private_ips = [var.NEXTCLOUD_PRIVATE_IP]
}

resource "aws_network_interface" "database_private_eni" {
    subnet_id = aws_subnet.private_instance.id
    security_groups = [ aws_security_group.private_instance.id ]
    private_ips = [var.DATABASE_PRIVATE_IP]
}

resource "aws_network_interface" "database_nat_eni" {
    subnet_id = aws_subnet.private_database.id
    security_groups = [aws_security_group.private_database.id]
}
