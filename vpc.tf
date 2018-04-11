provider "aws" {
	region = "us-west-2"
	access_key = "AKIAIJISQ54OXB7BDM5Q"
	secret_key = "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"
}
resource "aws_vpc" "myvpc" {
	cidr_block = "172.16.0.0/16"
	tags = {
	  Name = "TestVpc"
	}
}
resource "aws_subnet" "my_public_subnet" {
	vpc_id =  "${aws_vpc.myvpc.id}"
	cidr_block = "172.16.1.0/24"
	map_public_ip_on_launch = true
	availability_zone = "us-west-2a"
	tags = {
	  Name = "subnet-2a"
	}
}
resource "aws_subnet" "my_private1" {
	vpc_id = "${aws_vpc.myvpc.id}"
	cidr_block = "172.16.2.0/24"
	availability_zone = "us-west-2a"
	tags = {
	  Name = "subnet-private1"
	} 
}
resource "aws_subnet" "my_private2" {
	vpc_id = "${aws_vpc.myvpc.id}"
	cidr_block = "172.16.3.0/24"
	availability_zone = "us-west-2a"
	tags = {
	  Name = "subnet-private2"
	}
}
resource "aws_internet_gateway" "myigw" {
	vpc_id = "${aws_vpc.myvpc.id}"
	tags = {
	  Name = "Internet-gateway"
	}
}
resource "aws_route" "Internet_access" {
	route_table_id = "${aws_vpc.myvpc.main_route_table_id}"
	destination_cidr_block = "0.0.0.0/0"
	gateway_id = "${aws_internet_gateway.myigw.id}"
}
resource "aws_eip" "my_ip" {
	vpc = true
	depends_on = ["aws_internet_gateway.myigw"]
}
resource "aws_nat_gateway" "mynat" {
	allocation_id = "${aws_eip.my_ip.id}"
	subnet_id = "${aws_subnet.my_public_subnet.id}"
	depends_on = ["aws_internet_gateway.myigw"]
}
resource "aws_route_table" "private_route_table" {
	vpc_id = "${aws_vpc.myvpc.id}"
	tags {
	  Name = "Private route table"
	}
}
resource "aws_route" "private_route" {
	route_table_id = "${aws_route_table.private_route_table.id}"
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = "${aws_nat_gateway.mynat.id}"
}
resource "aws_route_table_association" "my-public-subnet-association" {
	subnet_id = "${aws_subnet.my_public_subnet.id}"
	route_table_id = "${aws_vpc.myvpc.main_route_table_id}"
}
resource "aws_route_table_association" "my-private1-assocition" {
	subnet_id = "${aws_subnet.my_private1.id}"
	route_table_id = "${aws_route_table.private_route_table.id}"
}
resource "aws_route_table_association" "my-private2-association" {
	subnet_id = "${aws_subnet.my_private2.id}"
	route_table_id = "${aws_route_table.private_route_table.id}"
}
