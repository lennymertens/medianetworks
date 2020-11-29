#3.1 load balancer
  resource "aws_lb" "tf-lb" {
    name               = "tf-lb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.tf_sg.id]
    subnets            = ["${aws_subnet.subnet1.id}", "${aws_subnet.subnet2.id}"]

  }

  #target group met instances erbij
  resource "aws_lb_target_group" "tf-tg" {
    name        = "tf-tg"
    port        = 80
    protocol    = "HTTP"
    vpc_id      = aws_vpc.terraform.id

    tags = {
      Name = "tf-tg"
    }
  }
  
  #webserver1
  resource "aws_lb_target_group_attachment" "tf_tga_1" {
    target_group_arn = aws_lb_target_group.tf-tg.arn
    target_id = "${aws_instance.webserver1.id}"
    port = 80
  }

  #webserver2
  resource "aws_lb_target_group_attachment" "tf_tga_2" {
    target_group_arn = aws_lb_target_group.tf-tg.arn
    target_id = "${aws_instance.webserver2.id}"
    port = 80
  }

  #webserver3
  resource "aws_lb_target_group_attachment" "tf_tga_3" {
    target_group_arn = aws_lb_target_group.tf-tg.arn
    target_id = "${aws_instance.webserver3.id}"
    port = 80
  }

  resource "aws_lb_listener" "tf_listener" {
    load_balancer_arn = aws_lb.tf-lb.arn
    port = 80
    protocol = "HTTP"
    default_action{
      type = "forward"
      target_group_arn = aws_lb_target_group.tf-tg.arn
    }
  }