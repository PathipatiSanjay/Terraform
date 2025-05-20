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

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

resource "aws_route_table_association" "my_rt_asc" {
    route_table_id = aws_route_table.my_rt.id
    subnet_id = aws_subnet.my_subnet.id      
}

resource "aws_network_acl" "my-nacl" {
    vpc_id = aws_vpc.my_vpc.id

    egress {
        protocol = "tcp"
        rule_no  =  100
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port =  0
        to_port = 65535
    }

    ingress {
        protocol = "tcp"
        rule_no = 100
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 65535
    }

    tags = {
      Name = "my_nacl"

    }
  
}


resource "aws_network_acl_association" "my_nacl_asc" {
    network_acl_id = aws_network_acl.my-nacl.id
    subnet_id = aws_subnet.my_subnet.id  
}

resource "aws_security_group" "my_sg" {
    name = "my_sg"
    description = "Allowing ssh,http"
    vpc_id = aws_vpc.my_vpc.id

    tags = {
      Name = "my-sg"
    }
}

resource "aws_vpc_security_group_ingress_rule" "my_sg_ssh_rule" {
    security_group_id = aws_security_group.my_sg.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 22
    ip_protocol = "tcp"
    to_port = 22  
}

resource "aws_vpc_security_group_ingress_rule" "my_sg_http_rule" {
    security_group_id = aws_security_group.my_sg.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 80
    ip_protocol = "tcp"
    to_port = 80 
}

resource "aws_vpc_security_group_egress_rule" "my_sg_outbound_rule" {
    security_group_id = aws_security_group.my_sg.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 0
    ip_protocol = "tcp"
    to_port = 65535  
}


resource "aws_key_pair" "my_ec2_key_pair" {
  key_name   = "my-ec2-instance-key"
  public_key = file("~/.ssh/my-ec2-key.pub") # Path on the Terraform server
}

resource "aws_instance" "my_instance" {
    ami = "ami-0f9de6e2d2f067fca"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.my_subnet.id
    security_groups = aws_security_group.my_sg.id
    key_name = aws_key_pair.my_ec2_key_pair.key_name
    tags ={
        Name = "my_instance"

    }
    
    associate_public_ip_address = "true"
  
}
