resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    tags = {
      "Name" = "public_route_table"
    }
}

resource "aws_route" "public-igw" {
    route_table_id = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "associate-subnet" {
    route_table_id = aws_route_table.public.id
    subnet_id = aws_subnet.public_subnet.id
}

resource "aws_route_table" "private_database" {
    vpc_id = aws_vpc.main.id
    tags = {
      "Name" = "private_database"
    }
}

resource "aws_route" "private-ngw" {
    route_table_id = aws_route_table.private_database.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
}

resource "aws_route_table_association" "associate-private_subnet" {
    route_table_id = aws_route_table.private_database.id
    subnet_id = aws_subnet.private_database.id
}