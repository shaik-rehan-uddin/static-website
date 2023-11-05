provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "my_s3_bucket" {
  bucket = var.site_domain
}

resource "aws_s3_bucket_public_access_block" "my_s3_bucket" {
  bucket                  = aws_s3_bucket.my_s3_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "my_s3_bucket" {
  bucket = aws_s3_bucket.my_s3_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "my_s3_bucket" {
  bucket = aws_s3_bucket.my_s3_bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "my_s3_bucket" {
  bucket = aws_s3_bucket.my_s3_bucket.id
  acl    = "public-read"
  depends_on = [
    aws_s3_bucket_ownership_controls.my_s3_bucket,
    aws_s3_bucket_public_access_block.my_s3_bucket
  ]
}

resource "aws_s3_bucket_policy" "my_s3_bucket" {
  bucket = aws_s3_bucket.my_s3_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          aws_s3_bucket.my_s3_bucket.arn,
          "${aws_s3_bucket.my_s3_bucket.arn}/*",
        ]
      },
    ]
  })

  depends_on = [
    aws_s3_bucket_public_access_block.my_s3_bucket
  ]
}

locals {
  website_filepath = "../website"
  content_types = {
    css  = "text/css"
    html = "text/html"
    js   = "application/javascript"
    json = "application/json"
    txt  = "text/plain"
  }
}

resource "aws_s3_object" "my_s3_bucket" {
  for_each     = fileset(local.website_filepath, "**")
  bucket       = aws_s3_bucket.my_s3_bucket.id
  key          = each.key
  source       = "${local.website_filepath}/${each.value}"
  acl          = "public-read"
  etag         = filemd5("${local.website_filepath}/${each.value}")
  content_type = lookup(local.content_types, element(split(".", each.value), length(split(".", each.value)) - 1), "text/plain")

  depends_on = [
    aws_s3_bucket_public_access_block.my_s3_bucket
  ]

}
