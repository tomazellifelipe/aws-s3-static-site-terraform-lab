terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }
  }
}

provider "aws" {
  region     = "us-east-2"
  access_key = var.access_key
  secret_key = var.secret_key
  default_tags {
    tags = {
      Owner = "felipe.tomazelli"
      Cost  = "terraform-lab"
    }
  }
}

resource "random_string" "random" {
  length  = 6
  special = false
  upper   = false
}

resource "aws_s3_bucket" "terraform_lab" {
  bucket        = "${var.name}-${random_string.random.result}"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "terraform_lab" {
  bucket = aws_s3_bucket.terraform_lab.bucket
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.terraform_lab.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "terraform_lab" {
  bucket = aws_s3_bucket.terraform_lab.id
  policy = templatefile("s3-policy.json",
    {
      bucket = aws_s3_bucket.terraform_lab.id
    }
  )
}

resource "aws_s3_object" "upload_object" {
  for_each     = fileset("html/", "*")
  bucket       = aws_s3_bucket.terraform_lab.id
  key          = each.value
  source       = "html/${each.value}"
  etag         = filemd5("html/${each.value}")
  content_type = "text/html"
}