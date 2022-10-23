resource "aws_cloudwatch_event_rule" "event_rule" {
  name                = var.cloudwatch_event_rule_name
  description         = var.cloudwatch_event_rule_description
  schedule_expression = var.cloudwatch_event_rule_rate
}

resource "aws_cloudwatch_event_target" "check_weather_at_time" {
  rule      = aws_cloudwatch_event_rule.event_rule.name
  target_id = "lambda"
  arn       = aws_lambda_function.main_weather.arn
}