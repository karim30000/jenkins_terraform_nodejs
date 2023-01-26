resource "aws_db_instance" "My-DB" {
  allocated_storage      = 200
  storage_type           = "gp2"
  db_name                = var.db_name
  engine                 = "mysql"
  engine_version         = "8.0.28"
  instance_class         = "db.t3.micro"
  username               = var.username
  password               = var.password
  port                   = "3306"
  db_subnet_group_name   = aws_db_subnet_group.rds-private-subnets.name
  vpc_security_group_ids = [aws_security_group.rds-sg.id]
  skip_final_snapshot    = true
  tags = {
    Name = var.rds_name
  }
  provisioner "local-exec" {
    command = <<EOT
      echo "RDS_HOSTNAME=${self.address}" > output.txt
      echo "RDS_USERNAME=${var.username}" >> output.txt
      echo "RDS_PASSWORD=${var.password}" >> output.txt
      echo "RDS_PORT=${self.port}" >> output.txt
    EOT
  }
}

resource "aws_db_subnet_group" "rds-private-subnets" {
  name       = "rds-private-subnets"
  subnet_ids = var.private-subnet-ids

  tags = {
    Name = "DB_subnet-group"
  }
}

resource "aws_security_group" "rds-sg" {
  name   = "rds-sg"
  vpc_id = var.vpc-id
  tags = {
    Name = var.rds_sg_tag
  }
}

resource "aws_security_group_rule" "rds-sg-inbound-allow-port3306" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = var.private-subnet-cidrs
  security_group_id = aws_security_group.rds-sg.id
}

resource "aws_security_group_rule" "rds-sg-outbound-allow-all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds-sg.id
}