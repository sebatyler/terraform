output "rich_kraken_cloudfront_storage_domain" {
  value = aws_cloudfront_distribution.rich_kraken_storage.domain_name
}

output "postgres_instance_public_ip" {
  value = module.oracle_postgres.instance_public_ip
}

output "postgres_instance_id" {
  value = module.oracle_postgres.instance_id
}
