
# Create s3 bucket
resource "aws_s3_bucket" "s3_static_website_resume" {
  bucket = "static-cloud-resume-website"
  
  
  tags = {
    name ="Cloud Resume Challenge"
  }
}

# Upload all files from the local websits folder
locals {
  website_files = fileset("${path.module}/../website", "**")
}

resource "aws_s3_object" "resume_website" {
  for_each =  toset(local.website_files)

  bucket = aws_s3_bucket.s3_static_website_resume.bucket  # reference bucket
  key = each.value 
  source = "${path.module}/../website/${each.value}"       # local path
  etag = filemd5("${path.module}/../website/${each.value}")
}