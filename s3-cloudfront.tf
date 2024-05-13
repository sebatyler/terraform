resource "aws_s3_bucket" "rich_kraken_storage" {
  bucket = "rich-kraken-storage"

  tags = {
    Name        = "rich_kraken_storage"
    Environment = "prod"
  }
}

resource "aws_s3_bucket_cors_configuration" "rich_kraken_cors_rule" {
  bucket = aws_s3_bucket.rich_kraken_storage.id

  cors_rule {
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_headers = ["*"]
    allowed_origins = ["http://localhost:8000", "https://rich.seba.kim"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_cloudfront_origin_access_control" "rich_kraken_oac" {
  name                              = "OAC for rich_kraken_storage"
  origin_access_control_origin_type = "s3"
  description                       = "OAC for accessing S3 bucket"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "rich_kraken_storage" {
  origin {
    domain_name              = aws_s3_bucket.rich_kraken_storage.bucket_regional_domain_name
    origin_id                = "S3-rich-kraken-storage"
    origin_access_control_id = aws_cloudfront_origin_access_control.rich_kraken_oac.id
  }
  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-rich-kraken-storage"

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

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "rich-kraken-storage CloudFront Distribution"
    Environment = "prod"
  }
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "allow_cloudfront" {
  bucket = aws_s3_bucket.rich_kraken_storage.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "s3:GetObject",
      Effect    = "Allow",
      Resource  = "${aws_s3_bucket.rich_kraken_storage.arn}/*",
      Principal = { "Service" : "cloudfront.amazonaws.com" },
      Condition = {
        StringEquals = {
          "aws:SourceArn" : "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.rich_kraken_storage.id}"
        }
      }
    }]
  })
}
