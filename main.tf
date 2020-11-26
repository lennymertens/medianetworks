provider "aws" {
  region = "eu-west-1"
}

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

  tags = {
    Name = "subnet1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.terraform.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true

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
    resource "aws_route_table" "tf_main_table" {
      vpc_id = aws_vpc.terraform.id

      route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.tf_gw.id
      }

      tags = {
        Name = "tf_main_table"
      }
    }
#2.3 instances met apache en php
resource "aws_instance" "webserver1" {
  ami           = "ami-0aef57767f5404a3c"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet1.id

  tags = {
    Name = "webserver1"
    Group = "tf_servers"
  }
}


resource "aws_instance" "webserver2" {
  ami           = "ami-0aef57767f5404a3c"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet1.id

  tags = {
    Name = "webserver2"
    Group = "tf_servers"
  }
}


resource "aws_instance" "webserver3" {
  ami           = "ami-0aef57767f5404a3c"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet2.id

  tags = {
    Name = "webserver3"
    Group = "tf_servers"
  }
}

resource "aws_lb_target_group" "tf_TargetGroup" {
  name        = "tf-example-lb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.terraform.id

  tags = {
    Name = "tf_TargetGroup"
  }
}
  #met een index.php file erbij
#3.1 load balancer
  #security group met instances erbij
#4.lambda function
#5.E3 bucket


