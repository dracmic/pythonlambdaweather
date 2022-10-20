data "aws_caller_identity" "current" {}

variable "region" {
  default = "eu-west-1"
}

locals {
  account_id          = data.aws_caller_identity.current.account_id
  ecr_repository_name = "python-lambda-weather"
  ecr_image_tag       = "latest"
}

resource "aws_s3_bucket" "weather_bucket" {
  bucket        = "weather-bucket-personal-epam"
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
    allowed_headers = ["Authorization", "Content-Length"]
    allowed_methods = ["GET", "POST"]
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

resource "aws_ecr_repository" "python_lambda_weather" {
  name                 = "pythonweather"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "null_resource" "ecr_image" {
  triggers = {
    python_file = md5(file("${path.module}/weathercode/weather.py"))
    docker_file = md5(file("${path.module}/weathercode/Dockerfile"))
  }
  provisioner "local-exec" {
    command = <<EOF
           aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com
           cd ${path.module}/weathercode
           docker build --platform=linux/amd64 -t ${aws_ecr_repository.python_lambda_weather.repository_url}:${local.ecr_image_tag} .
           docker push ${aws_ecr_repository.python_lambda_weather.repository_url}:${local.ecr_image_tag}
       EOF
  }
}

resource "aws_iam_role" "lambda-function-role" {
  name               = "python_weather_lambda_role"
  assume_role_policy = <<EOF
 {
   "Version": "2012-10-17",
   "Statement": [
       {
           "Action": "sts:AssumeRole",
           "Principal": {
               "Service": "lambda.amazonaws.com"
           },
           "Effect": "Allow"
       }
   ]
}
 EOF
}

resource "aws_cloudwatch_event_rule" "every_one_hour" {
  name                = "every-one-hour"
  description         = "Fires every one hour"
  schedule_expression = "rate(1 hour)"
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda-function-role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_lambda_function" "main_weather" {
  image_uri     = "${aws_ecr_repository.python_lambda_weather.repository_url}:latest" # repo and tag
  package_type  = "Image"
  function_name = "Weather_Lambda"
  role          = aws_iam_role.lambda-function-role.arn
  timeout       = 300
  publish       = true
  depends_on = [
    null_resource.ecr_image,
    aws_iam_role.lambda-function-role,
    aws_iam_role_policy_attachment.lambda_policy
  ]

  environment {
    variables = {
      API_KEY   = "b6e2002b08b8d2fe34597ff2d81f684d",
      Location  = "Prague,Prague,CZ"
      s3_bucket = "${aws_s3_bucket.weather_bucket.id}"
    }
  }
}


resource "aws_cloudwatch_event_target" "check_weather_every_one_hour" {
  rule      = aws_cloudwatch_event_rule.every_one_hour.name
  target_id = "lambda"
  arn       = aws_lambda_function.main_weather.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_weather" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main_weather.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_one_hour.arn
}
