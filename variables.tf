
variable "cloudwatch_event_rule_name" {
  type    = string
  default = "every-one-hour"
}

variable "cloudwatch_event_rule_description" {
  type    = string
  default = "Fires every one hours"
}

variable "cloudwatch_event_rule_rate" {
  type    = string
  default = "rate(1 hour)"
}

variable "ecr_name" {
  type    = string
  default = "pythonweather"
}

variable "lambda_role_name" {
  type    = string
  default = "python_weather_lambda_role"
}

variable "lambda_function_name" {
  type    = string
  default = "Weather_Lambda"
}

variable "s3_bucket_name" {
  type    = string
  default = "weather-bucket-personal-epam"
}

variable "location" {
  type    = string
  default = "Prague,Prague,CZ"
}
variable "region" {
  default = "eu-west-1"
}


variable "api_key" {
  type    = string
  default = "xxxx"
}
