data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.bastion_pub_subnet_id
  vpc_security_group_ids      = [aws_security_group.bastion-sg.id]
  availability_zone           = var.bastion_avail_zone
  associate_public_ip_address = true
  key_name                    = var.key_name
  root_block_device {
    volume_type = "gp2"
    volume_size = 10
  }
  tags = {
    Name = "Bastion-Server"
  }
  provisioner "local-exec" {
    command = "echo ${self.public_ip} > bastion-public_ip.txt"
  }
}

resource "aws_security_group" "bastion-sg" {
  name   = "bastion-sg"
  vpc_id = var.vpc_id
  tags = {
    Name = "bastion-sg"
  }
}

resource "aws_security_group_rule" "inbound_allow_shh_from_everywhere" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion-sg.id
}

resource "aws_security_group_rule" "outbound_allow-all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion-sg.id
}

resource "aws_security_group" "lb_sg" {
  name   = "lb-sg"
  vpc_id = var.vpc_id
  tags = {
    Name = "lb_sg"
  }
}

resource "aws_security_group_rule" "inbound_allow_shh_from_all" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb_sg.id
}

resource "aws_security_group_rule" "outbound_allow_all" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb_sg.id
}

resource "aws_security_group" "app-sg" {
  name   = "app-sg"
  vpc_id = var.vpc_id
  tags = {
    Name = "app-sg"
  }
}

resource "aws_security_group_rule" "inbound_allow_shh_from_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.bastion_pub_subnet_cidr
  security_group_id = aws_security_group.app-sg.id
}

resource "aws_security_group_rule" "inbound_allow_port3000_from_vpcCidr" {
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.app-sg.id
}

resource "aws_security_group_rule" "outbound-allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app-sg.id
}

resource "aws_launch_configuration" "web_config" {
  name_prefix     = "app_launch_config"
  image_id        = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [aws_security_group.app-sg.id]
  root_block_device {
    volume_type = "gp2"
    volume_size = 10
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app_auto_scaling" {
  name                 = "app_asg"
  launch_configuration = aws_launch_configuration.web_config.name
  vpc_zone_identifier  = var.private_subnet_ids
  health_check_grace_period = 300
  health_check_type         = "ELB"
  min_size             = 1
  desired_capacity     = 2
  max_size             = 3
  target_group_arns    = [aws_lb_target_group.lb_target_group.arn]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "app_lb" {
  name               = "AppLB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = var.public_subnet_ids
  tags = {
    Environment = "app_lb"
  }
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}

resource "aws_lb_listener_rule" "lb_listener_rule" {
  listener_arn = aws_lb_listener.lb_listener.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

resource "aws_lb_target_group" "lb_target_group" {
  name     = "LBTargetGroup"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  slow_start = 60
  health_check {
    interval            = 10
    timeout             = 8
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }
}

resource "null_resource" "run-command" {
  depends_on = [aws_autoscaling_group.app_auto_scaling, aws_launch_configuration.web_config]
  provisioner "local-exec" {
    command = <<EOT
      aws ec2 describe-instances --filters "Name=subnet-id,Values=${var.private_subnet_ids[0]}" --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text > AppPvtIPS.txt
      aws ec2 describe-instances --filters "Name=subnet-id,Values=${var.private_subnet_ids[1]}" --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text >> AppPvtIPS.txt
    EOT
  }
}

