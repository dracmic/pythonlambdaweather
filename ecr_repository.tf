
resource "aws_ecr_repository" "python_lambda_weather" {
  name                 = var.ecr_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
}
