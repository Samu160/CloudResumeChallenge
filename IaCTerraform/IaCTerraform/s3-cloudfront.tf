/*
# Create s3 bucket
resource "aws_s3_bucket" "s3_static_website_resume" {
  bucket = "static-cloud-resume-website"


  tags = {
    name = "Cloud Resume Challenge"
  }
}

# Upload all files from the local websits folder
locals {
  website_files = fileset("${path.module}/../website", "**")
}

resource "aws_s3_object" "resume_website" {
  for_each = toset(local.website_files)

  bucket = aws_s3_bucket.s3_static_website_resume.bucket # reference bucket
  key    = each.value
  source = "${path.module}/../website/${each.value}" # local path
  etag   = filemd5("${path.module}/../website/${each.value}")
}


# Create Iam policy for origin bucket 
data "aws_iam_policy_document" "origin_bucket_policy" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.s3_static_website_resume.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.resume_distribution.arn]
    }
  }

}

# allows origin access identity to read from the bucket
resource "aws_s3_bucket_policy" "origin_bucket_policy" {
  bucket = aws_s3_bucket.s3_static_website_resume.bucket
  policy = data.aws_iam_policy_document.origin_bucket_policy.json
}

# local variable for origin id
locals {
  s3_origin_id = "myS3Origin"
}

# origin access control configuration
resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "default-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# creation of cloudfront distribution
resource "aws_cloudfront_distribution" "resume_distribution" {
  origin {
    domain_name              = aws_s3_bucket.s3_static_website_resume.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Cloud Resume Distribution"
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "allow-all"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
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
*/