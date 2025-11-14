# Create Iam policy for CloudFront
data "aws_iam_policy_document" "cloud-front-policy" {
  statement {
    sid = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"
    
    principals {
      type = "Service"
      identifiers = "cloudfront.amazonaws.com"
    }

    actions = [
        "s3:GetObject"
    ]

    resources = [
        "${aws_s3_bucket.s3_static_website_resume.arn}"
    ]

    condition {
      test = "StringEquals"
      variable = "AWS:SourceArn"
      values = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
  
}

# Creation of CloudFront distribution

