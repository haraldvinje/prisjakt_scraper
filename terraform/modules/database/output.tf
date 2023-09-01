output "database_address" {
  value = aws_db_instance.prisjakt_scraper_db.address
}

output "database_port" {
  value = aws_db_instance.prisjakt_scraper_db.port
}

output "database_arn" {
  value = aws_db_instance.prisjakt_scraper_db.arn
}

output "database_credentials_secret_arn" {
  value = aws_db_instance.prisjakt_scraper_db.master_user_secret[0].secret_arn
}
