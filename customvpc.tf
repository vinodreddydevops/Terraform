provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_keys}"
  region = "${var.aws_region}"
  }


resource "aws_vpc" "myvpc" {
  cidr_block = "${var.vpc_cidr}"
  tags {
    Name = "My custom vpc"
 }
}

resource "aws_subnet" "mypublic_network" {
 vpc_id = "${aws_vpc.myvpc.id}"
 cidr_block = "${var.public_subnet_cidr}"
 availability_zone = "us-west-2a"
 tags {
   Name = "Public Subnet"
 }
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = "${aws_vpc.myvpc.id}"
  tags {
    Name = "my IGW"
 }
}


resource "aws_route_table" "mypublic" {
    vpc_id = "${aws_vpc.myvpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.myigw.id}"
    }

    tags {
        Name = "Public Subnet"
    }
}

resource "aws_route_table_association" "public_subnet_association" {
    subnet_id = "${aws_subnet.mypublic_network.id}"
    route_table_id = "${aws_route_table.mypublic.id}"
}

resource "aws_subnet" "myprivate_network" {
 vpc_id = "${aws_vpc.myvpc.id}"
 cidr_block = "${var.private_subnet_cidr1}"
 availability_zone = "us-west-2b"
 tags {
   Name = "my Private subnet 1"
 }
}


