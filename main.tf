# Terraform Block: https://developer.hashicorp.com/terraform/language/settings 
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }
  }
}

# Provider Block: https://developer.hashicorp.com/terraform/language/providers
# AWS: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
  token      = var.token
  default_tags {
    tags = {
      Owner = "felipe.tomazelli"
      Cost  = "terraform-lab"
    }
  }
}


# Resources Block: https://developer.hashicorp.com/terraform/language/resources
# random_string: https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_string" "random" {
  length  = 6
  special = false
  upper   = false
}

# aws_s3_bucket: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "terraform_lab" {
  bucket        = "${var.name}-${random_string.random.result}"
  force_destroy = true
}

# aws_s3_bucket_website_configuration: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration
resource "aws_s3_bucket_website_configuration" "terraform_lab" {
  bucket = aws_s3_bucket.terraform_lab.bucket
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

# aws_s3_bucket_public_access_block: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.terraform_lab.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# templatefile: https://developer.hashicorp.com/terraform/language/functions/templatefile
# aws_s3_bucket_policy: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy
resource "aws_s3_bucket_policy" "terraform_lab" {
  bucket = aws_s3_bucket.terraform_lab.id
  policy = templatefile("s3-policy.json",
    {
      bucket = aws_s3_bucket.terraform_lab.id
    }
  )
}
# fileset: https://developer.hashicorp.com/terraform/language/functions/fileset
# filemd5: https://developer.hashicorp.com/terraform/language/functions/filemd5
# aws_s3_object: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object
resource "aws_s3_object" "upload_object" {
  for_each     = fileset("html/", "*")
  bucket       = aws_s3_bucket.terraform_lab.id
  key          = each.value
  source       = "html/${each.value}"
  etag         = filemd5("html/${each.value}")
  content_type = "text/html"
}