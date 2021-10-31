provider "aws" {
    region = var.region
}

resource "aws_vpc" "main" {
    cidr_block = "192.168.0.0/16"
    tags = {
        "Name" = "sds_vpc"
    }
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.main.id
    cidr_block = "192.168.0.0/24"
    availability_zone = var.availability_zone
    tags = {
        "Name" = "public_subnet"
    }
    depends_on = [
        aws_internet_gateway.igw
    ]
}

resource "aws_subnet" "private_database" {
    vpc_id = aws_vpc.main.id
    cidr_block = "192.168.1.0/24"
    availability_zone = var.availability_zone
    tags = {
        "Name" = "private_database"
    }
}

resource "aws_subnet" "private_instance" {
    vpc_id = aws_vpc.main.id
    cidr_block = "192.168.2.0/24"
    availability_zone = var.availability_zone
    tags = {
        "Name" = "private_instance"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id

    tags = {
        "Name" = "sds_igw"
    }
}

resource "aws_nat_gateway" "ngw" {
    allocation_id = aws_eip.public_database_ip.id
    subnet_id = aws_subnet.public_subnet.id
    
    tags = {
        "Name" : "sds-ngw"
    }
}


resource "aws_eip" "public_ip" {
    vpc = true
    depends_on = [
        aws_internet_gateway.igw
    ]
    network_interface = aws_network_interface.nextcloud_public_eni.id
}

resource "aws_eip" "public_database_ip" {
    vpc = true
}

resource "aws_key_pair" "key" {
    key_name = "db_instance_key"
    public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC7QWkhpAxrUfntxfIl3aoS3mu2El5FbaDBlBseSLve4 keng2@KengAcethylene-LAPTOP"
}


output "public_ip" {
    value = aws_instance.nextcloud.public_ip
}

output "nextcloud_private_ip" {
    value = aws_instance.nextcloud.private_ip
}

output "database_private_ip" {
    value = aws_instance.database.private_ip
}