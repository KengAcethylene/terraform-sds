resource "aws_network_interface" "nextcloud_public_eni" {
    subnet_id = aws_subnet.public_subnet.id
    security_groups = [ aws_security_group.public_sg_group.id ]
}
