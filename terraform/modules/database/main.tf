resource "aws_security_group" "db_security_group" {

  name   = "${var.database_name}-security-group"
  vpc_id = var.vpc_id
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.container_security_group_id, var.bastion_host_security_group_id]
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.database_name}-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "prisjakt_scraper_db" {
  identifier                  = "${var.database_name}-instance"
  db_name                     = var.database_name
  engine                      = "postgres"
  engine_version              = "15.3"
  allow_major_version_upgrade = true
  instance_class              = "db.t3.micro"
  username                    = "postgres"
  backup_retention_period     = 7
  backup_window               = "07:00-09:00"
  maintenance_window          = "sun:05:00-sun:06:00"
  manage_master_user_password = true
  vpc_security_group_ids      = [aws_security_group.db_security_group.id]
  allocated_storage           = 20
  storage_type                = "gp2"
  publicly_accessible         = false
  skip_final_snapshot         = true
  db_subnet_group_name        = aws_db_subnet_group.db_subnet_group.name
  ca_cert_identifier          = "rds-ca-rsa4096-g1"
}

resource "aws_db_snapshot" "prisjakt_scraper_db_snapshot" {
  db_instance_identifier = aws_db_instance.prisjakt_scraper_db.identifier
  db_snapshot_identifier = "${var.database_name}-snapshot"
}
