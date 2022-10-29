# Create RDS instance

resource "aws_db_subnet_group" "db-subnet-group" {
  name = "db_subnet_group"
  subnet_ids = var.subnets.*.id

  tags = {
    Name = "db_subnet_group"
  }
}

resource "aws_security_group" "rds-sg" {
  name        = "RDSSG"
  description = "Allows application tier to access the RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    description     = "EC2 to MYSQL"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = var.from_sgs.*.id
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds_sg"
  }
}

resource "aws_db_instance" "rds" {
  # . If unspecified, will be created in the default VPC, or in EC2 Classic, if available.
  db_subnet_group_name   = aws_db_subnet_group.db-subnet-group.id
  # When configured, the upper limit to which Amazon RDS can automatically scale the storage of the DB instance
  allocated_storage      = var.allocated_storage
  # The database engine.
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  multi_az               = var.multi_az
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  # Determines whether a final DB snapshot is created before the DB instance is deleted.
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds-sg.id]
} 