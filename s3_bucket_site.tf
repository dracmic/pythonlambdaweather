resource "aws_s3_bucket" "weather_bucket" {
  bucket        = var.s3_bucket_name
  force_destroy = "true"
}

resource "aws_s3_bucket_policy" "weather_bucket_policy" {
  bucket = aws_s3_bucket.weather_bucket.id
  policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "${aws_s3_bucket.weather_bucket.arn}/*"
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_acl" "weather_bucket_acl" {
  bucket = aws_s3_bucket.weather_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_cors_configuration" "weather_bucket_cors" {
  bucket = aws_s3_bucket.weather_bucket.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "PUT"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_website_configuration" "weather_bucket_website_config" {
  bucket = aws_s3_bucket.weather_bucket.bucket
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "404.html"
  }

}