output "s3_bucket_name" {
  description = "The name of the S3 bucket"
 value       = aws_s3_bucket.static_web.id
}

output "s3_bucket_website_endpoint" {
  description = "The website endpoint of the S3 bucket"
  value       = aws_s3_bucket_website_configuration.static_web.website_endpoint
}
output "cloudfront_distribution_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}