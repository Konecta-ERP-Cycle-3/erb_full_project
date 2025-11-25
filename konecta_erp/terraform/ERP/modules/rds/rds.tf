resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_db_instance" "this" {
  identifier              = "${var.project_name}-${var.environment}-db"
  engine                  = "sqlserver-ex"
  engine_version          = "15.00"
  instance_class          = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = false

  # SQL Server - databases are created via migrations, not here
  username = var.db_username
  password = var.db_password
  # Note: db_name is not used for SQL Server - databases created via EF migrations

  vpc_security_group_ids  = [var.rds_sg_id]
  db_subnet_group_name    = aws_db_subnet_group.this.name
  skip_final_snapshot     = true
  publicly_accessible     = false
  backup_retention_period = 0 # If you want free tier
  license_model           = "license-included"

  tags = {
    Name = "${var.project_name}-${var.environment}-rds"
  }
}
