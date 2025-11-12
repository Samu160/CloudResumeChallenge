
# Create s3 bucket
resource "aws_s3_bucket" "s3_static_website_resume" {
  bucket = "static-cloud-resume-website"
  
  tags = {
    name ="Cloud Resume Challenge"
  }
}

# Upload all files from the local websits folder
locals {
  website_files = fileset("../CloudResumeChallenge/website", "*")
}

resource "aws_s3_object" "resume_website" {
  for_each = {for file in local.website_files : file => file} # loop to upload all files in local

  bucket = aws_s3_bucket.s3_static_website_resume.bucket  # reference bucket
  key = "each.value" 
  source = "../CloudResumeChallenge/website/${each.value}"       # local path
  etag = filemd5("../CloudResumeChallenge/website/${each.value}")
}

# Enable static hosting

resource "aws_s3_bucket_website_configuration" "resume_website" {
  bucket = aws_s3_bucket.s3_static_website_resume.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
