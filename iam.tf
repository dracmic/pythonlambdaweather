resource "aws_iam_role" "lambda-function-role" {
  name               = var.lambda_role_name
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

resource "aws_iam_policy" "ecr_policy" {
  name        = "ecr_allow_policy_to_lambda"
  path        = "/"
  description = "ecr_allow_policy_to_lambda"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:Describe*",
          "ecr:Get*",
          "ecr:TagResource",
          "ecr:UntagResource",
        ]
        Effect   = "Allow"
        Resource = [ "${aws_ecr_repository.python_lambda_weather.arn}/*","${aws_ecr_repository.python_lambda_weather.arn}"]
      },
    ]
  })
}

resource "aws_iam_policy" "s3_policy" {
  name        = "s3_allow_policy_to_lambda"
  path        = "/"
  description = "s3_allow_policy_to_lambda"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:List*",
          "s3-object-lambda:List*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:*",
          "s3-object-lambda:*"
        ]
        Effect   = "Allow"
        Resource = [
        "${aws_s3_bucket.weather_bucket.arn}/*",
        "${aws_s3_bucket.weather_bucket.arn}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda-function-role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_policy_ecr" {
  role       = aws_iam_role.lambda-function-role.name
  policy_arn = aws_iam_policy.ecr_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_policy_logs" {
  role       = aws_iam_role.lambda-function-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_weather" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main_weather.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.event_rule.arn
}