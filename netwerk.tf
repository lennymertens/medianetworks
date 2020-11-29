#1.1 VPC, met 2 subnets
resource "aws_vpc" "terraform" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "terraform"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.terraform.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-1a"

  tags = {
    Name = "subnet1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.terraform.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-1b"

  tags = {
    Name = "subnet2"
  }
}

  #internet gateway
resource "aws_internet_gateway" "tf_gw" {
  vpc_id = aws_vpc.terraform.id

  tags = {
    Name = "tf_gw"
  }
}
  #routing table
    #connecteer gateway naar vpc
    resource "aws_default_route_table" "tf_main_table" {
      default_route_table_id = aws_vpc.terraform.default_route_table_id

      route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.tf_gw.id
      }

      tags = {
        Name = "tf_main_table"
      }
    }