#2.3 instances met apache en php
resource "aws_instance" "webserver1" {
  ami           = "ami-0aef57767f5404a3c"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.tf_sg.id]

  key_name = "terraKey"

  user_data = "${file("webserver.sh")}"

  depends_on = [local_file.index]
  
  provisioner "file" {
    source = "index.php"
    destination = "/tmp/index.php"

    connection {
      user = "ubuntu"
      host = self.public_ip
      type = "ssh"
      private_key = "${file("terraKey.pem")}"
    }
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
  vpc_security_group_ids = [aws_security_group.tf_sg.id]

  key_name = "terraKey"

  depends_on = [local_file.index]

  user_data = "${file("webserver.sh")}"
  
  provisioner "file" {
    source = "index.php"
    destination = "/tmp/index.php"

    connection {
      user = "ubuntu"
      host = self.public_ip
      type = "ssh"
      private_key = "${file("terraKey.pem")}"
    }
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
  vpc_security_group_ids = [aws_security_group.tf_sg.id]

  key_name = "terraKey"

  user_data = "${file("webserver.sh")}"
  
  depends_on = [local_file.index]

  provisioner "file" {
    source = "index.php"
    destination = "/tmp/index.php"

    connection {
      user = "ubuntu"
      host = self.public_ip
      type = "ssh"
      private_key = "${file("terraKey.pem")}"
    }
  }


  tags = {
    Name = "webserver3"
    Group = "tf_servers"
  }
}

resource "aws_security_group" "tf_sg" {
  name = "tf_sg"
  vpc_id = aws_vpc.terraform.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


  #met een index.php file erbij