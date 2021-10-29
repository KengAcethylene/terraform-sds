# resource "aws_security_group" "sg_db" {
#   name = "sg_db"
# }

# resource "aws_security_group_rule" "SSH" {
#   type = "ingress"
#   from_port = 22
#   to_port = 22
#   protocol = "tcp"
#   cidr_blocks = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.sg_db.id
# }

# resource "aws_security_group_rule" "ALLOW_ALL" {
#   type = "egress"
#   from_port = 0
#   to_port = 0
#   protocol = "-1"
#   cidr_blocks = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.sg_db.id
# }

# data "cloudinit_config" "database_init" {
#   gzip = false
#   base64_encode = false
#   part {
#     content_type = "text/cloud-config"
#     content = file("./database_init.yml")
#   }
# }



# resource "aws_instance" "mariadb" {
#   ami = var.ami
#   instance_type = var.instance_type
#   vpc_security_group_ids = [aws_security_group.sg_db.id]

#   user_data = data.cloudinit_config.database_init.rendered
#   tags = var.tags
# }

# output "public_ip" {
#   value = aws_instance.mariadb.public_ip
# }