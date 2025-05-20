resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "my-vpc"
      
    }
  
}

resource "aws_subnet" "my_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.0.0/20"
    map_public_ip_on_launch = "true"
    tags = {
      Name = "my-subnet"

    }
}

resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id
    tags = {
      Name = "my-igw"
    }

}


resource "aws_route_table" "my_rt" {
    vpc_id = aws_vpc.my_vpc.id
    route = {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_igw.id    
    }
  
}

resource "aws_route_table_association" "my_rt_asc" {
    route_table_id = aws_route_table.my_rt.id
    subnet_id = aws_subnet.my_subnet.id      
}