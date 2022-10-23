
resource "aws_lambda_function" "main_weather" {
  image_uri     = "${aws_ecr_repository.python_lambda_weather.repository_url}:latest" # repo and tag
  package_type  = "Image"
  function_name = var.lambda_function_name
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
      API_KEY   = "${var.api_key}",
      Location  = "${var.location}"
      s3_bucket = "${aws_s3_bucket.weather_bucket.id}"
    }
  }
}

