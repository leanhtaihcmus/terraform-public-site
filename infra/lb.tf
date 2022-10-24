# This file will create an application load balancer named "front-end-lb"

# you can see here that we are referring to the security group and subnets that we have created earlier
resource "aws_lb" "front_end" {
  name = "front-end-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.main_sg.id]
  subnets = aws_subnet.public_subnets.*.id
  
  enable_deletion_protection = false
}

# The rest of the file, create, a load balancer rule, a target group on port 80, 
# and a target group attachement, that attaches the instance we will create to 
# the load balancer target group
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}

resource "aws_lb_target_group" "front_end" {
  name = "front-end-lb-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "front_end" {
  count = length(aws_subnet.public_subnets)
  target_group_arn = aws_lb_target_group.front_end.arn
  target_id = aws_instance.front_end[count.index].id
  port = 80
}
