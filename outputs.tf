output "s3_bucket_id" {
  description = "Bucket endpoint."
  value       = aws_s3_bucket_website_configuration.terraform_lab.website_endpoint
}