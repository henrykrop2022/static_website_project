locals {
  files = fileset(var.local_folder_path, "**/*")
}

# resource "aws_s3_bucket" "static_web" {
#   bucket = var.bucket_name

#   website {
#     index_document = "index.html"
#     error_document = "error.html"
#   }

#   tags = {
#     Name        = "My bucket"
#     Environment = "Dev"
#   }
# }
resource "aws_s3_bucket" "static_web" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_website_configuration" "static_web" {
  bucket = aws_s3_bucket.static_web.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
resource "aws_s3_bucket_public_access_block" "static_web" {
  bucket                  = aws_s3_bucket.static_web.id
  block_public_acls       = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "static_web_policy" {
  bucket = aws_s3_bucket.static_web.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.static_web.id}/*"
      }
    ]
  })
}


resource "aws_s3_object" "files" {
  for_each = { for file in local.files : file => file }

  bucket      = aws_s3_bucket.static_web.bucket
  key         = each.value
  source      = "${var.local_folder_path}\\${each.value}"
  etag        = filebase64sha256("${var.local_folder_path}\\${each.value}")
  acl         = "private"
  content_type = lookup({
    "html" = "text/html"
    "css"  = "text/css"
    "js"   = "application/javascript"
    "png"  = "image/png"
    "jpg"  = "image/jpeg"
    "jpeg" = "image/jpeg"
    "gif"  = "image/gif"
    "svg"  = "image/svg+xml"
  }, regex("[^.]+$", each.value), "application/octet-stream")
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.static_web.bucket_regional_domain_name
    origin_id   = var.bucket_name
  }

  enabled             = true
  is_ipv6_enabled     = false
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.bucket_name

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}