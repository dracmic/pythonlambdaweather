data "aws_caller_identity" "current" {}

locals {
  account_id          = data.aws_caller_identity.current.account_id
  ecr_repository_name = var.ecr_name
  ecr_image_tag       = "latest"
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