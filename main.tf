provider "aws" {
  region = "eu-west-1"
}

resource "aws_key_pair" "custom-key" {
  key_name   = "terraKey"
  public_key = "ssh-rsa MIIEpAIBAAKCAQEAgLF3WEHXrmY2fUvYaXpNOkSmbxaAGuNV5G0NBzc/FOmvpru7lsjAqMjcsE3ZRMWlcMuohLoW6YSQvzh4GUeLiwBQD4izJMdV09p+rLZGf2b219VNqS8s1WddXCnpGjRut1lEtjTOb2Gz+k6V1z/Zmdjb9bq5s/9t1zHrLWUWxdt8xvKMaBTN5Y1bOw01HgBeD/AAElTTANVXixn44vXbdWt5Vcf42frojbg1kEaiDCIkaGm0y/ESCLhbqMut0aXQiPc5gombwqKyw9An5eeLxpmLzhf0noNTagmyTkYaoZ1O3MvAtSwSvvond6a6MQUrQADFT1pRVkMMOg2JEdMofQIDAQABAoIBAEjz0SKf2IMNgDAQ8bIBWYwBZJOunpofaw5dXzhK8iCJxD/xRgrY7JYBn1D2IIciv4EsgfATiW+A7YjomvRBoXH/kGLt7BeaRCYfQxXnEhmgpad+TFLu4ixrNvpK69AmDuky2oercaakLSFksP5fPJxA2Zf37NODpaGKs7V9C6bGzcEU/5WgmuACuddrQOmtK0RxLg7iaOYSZeI6IsLfENtBYcKjNkhWnSUHHCi9xFp1BSQ6Vfn0ymAkxSxByF9a4wUOmzPdI6nMbtO2FgtLfB3PfS260r0UNNj1VI7EoXxLHyQ6Ah+/nTQ27O8w89/BXymIjcWfNRqrMKdUgCGVcmECgYEA4dm+x2eVUD05UA88nOnQK4+cJ6NFm/d0s3OLtDiHU7TDxejpCAAWFZXM3TpfDUvM/Vczt0eROZ7lggkiGYCoBKY46LxrP1gqZqy3c6uqhODsp2pmIXFvJHO1qSrWJcmooxYP1aeb6KT4XPt8MrzacEs39VFfsLvE+w1i2xxLcJUCgYEAkd9zLI82Rc2qVo4zcpgozcf7WbKl5cUoFOWeNOuUG5CY1lrGnCcOxZ3VjFWkrXsXYR7YMP1EpSVzv35cCGsgW6tipTzw7uhkRKy7EtQgfUPnIFhBgjI0uqwHzJvmpEpqIqrvgBFxyIPq61w22zajJcVl+4ip0GDUBw4h7bEGVkkCgYEAgrIEEdaidFWJpge7Nr6jZaHsZo+4R4JSuUoDLV6NCWaQ6CVZPPT30rPmYptVyBb2YCCnX8d9hc+q1q48Wm+2S0J5qkzm7zgxCUunubs8qTqUGGmdAntnKrv/Aw8z75gcC4xHy4b71QwqYXxyqdXZvqP4lPDrJBX07qcXbt6X1WUCgYBFUhLBki0QbvQLvffk9Tou0GI59hOwZUju5U+RhoITt1tqQikv+7+hWagp0Gk5p80sciP64+DDOlEPJ1VFCuONrJxsOdGlNvqvSAZ+pB/sZ2BmlopK/ODh9O6f5VZtrI9TejfmfGO+DjKNNn07H3PYdz5HkmJgjCM2Vxj4g6+nQQKBgQCk1Dhi9bDry6LgFrW/HsXWOmicTGS7goTpaKs2cF2Gyn0F2nnzlm1+/y4Xr1qCH/w3fTuUXeWFS1opuSYt10zcEx0TJA9PwAAoPhyX4fl3esHATweVpEUQDKgOcXUmqhQrW1dGEq8wn1reeG7XnvUAX+bs9RAH+/9SmXGHztIvoQ=="
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

  key_name = "terraKey"

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",
      "sudo apt-get install apache2 php php-mysql -y"
    ]
  }

  provisioner "file" {
    source = "index.php"
    destination = "/var/www/html/index.php"
  }

  connection {
    host = self.public_ip
    type = "ssh"
  }

  tags = {
    Name = "webserver1"
    Group = "tf_servers"
  }
}


resource "aws_instance" "webserver2" {
  ami           = "ami-0aef57767f5404a3c"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet1.id

  key_name = "terraKey"

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",
      "sudo apt-get install apache2 php php-mysql -y"
    ]
  }

  provisioner "file" {
    source = "index.php"
    destination = "/var/www/html/index.php"
  }

  connection {
    host = self.public_ip
    type = "ssh"
  }

  tags = {
    Name = "webserver2"
    Group = "tf_servers"
  }
}


resource "aws_instance" "webserver3" {
  ami           = "ami-0aef57767f5404a3c"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet2.id

  key_name = "terraKey"

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",
      "sudo apt-get install apache2 php php-mysql -y"
    ]
  }

  provisioner "file" {
    source = "index.php"
    destination = "/var/www/html/index.php"
  }

  connection {
    host = self.public_ip
    type = "ssh"
  }

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

  #target group met instances erbij
#4.lambda function
#5.E3 bucket


