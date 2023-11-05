output "website_bucket_name" {
  description = "Name (id) of the bucket"
  value       = aws_s3_bucket.my_s3_bucket.id
}

output "bucket_endpoint" {
  description = "Bucket endpoint"
  value       = aws_s3_bucket_website_configuration.my_s3_bucket.website_endpoint
}

output "domain_name" {
  description = "Website endpoint"
  value       = var.site_domain
}
