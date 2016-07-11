
variable "cloudflare_email" {}
variable "cloudflare_api_key" {}
variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}

variable "bucket" {}
variable "region" {}
variable "subdomain" {}

provider "cloudflare" {
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_api_key}"
}

provider "aws" {
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
  region = "${var.region}"
}

resource "aws_s3_bucket" "pro_cdn" {
  bucket = "${var.bucket}"
  acl = "public-read"
  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AddPerm",
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::${var.bucket}/*"
      }
    ]
  }
  EOF

  website {
    index_document = "index.html"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_cloudfront_distribution" "pro" {
  origin {
    origin_id = "S3BucketOrigin"
    domain_name = "${aws_s3_bucket.pro_cdn.id}.s3.amazonaws.com"
    s3_origin_config {}
  }

  enabled = true
  comment = "${var.subdomain}.bauscode.com"
  aliases = ["${var.subdomain}.bauscode.com"]

  default_cache_behavior {
    allowed_methods = ["HEAD", "GET", "OPTIONS"]
    cached_methods = ["HEAD", "GET"]

    target_origin_id = "S3BucketOrigin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 60
    default_ttl            = 7200
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_record" "pro" {
  domain = "bauscode.com"
  name = "${var.subdomain}"
  value = "${aws_cloudfront_distribution.pro.domain_name}"
  type = "CNAME"

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_record" "pro_cdn" {
  domain = "bauscode.com"
  name = "cdn.${var.subdomain}"
  value = "${aws_cloudfront_distribution.pro.domain_name}"
  type = "CNAME"

  lifecycle {
    prevent_destroy = true
  }
}
