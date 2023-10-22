provider "aws" {
  region = "ap-northeast-2"
}

data "aws_iam_role" "existing_role" {
  name = "lambda_role"
}

locals {
  lambda_role_arn = try(data.aws_iam_role.existing_role.arn, null)
}

resource "aws_iam_role" "lambda_role" {
  count = local.lambda_role_arn == null ? 1 : 0

  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = local.lambda_role_arn != null ? data.aws_iam_role.existing_role.name : aws_iam_role.lambda_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "this" {
  filename      = "lambda_function_payload.zip"
  function_name = "lambda_function"
  handler       = "lambda_function.lambda_handler"
  role          = local.lambda_role_arn != null ? data.aws_iam_role.existing_role.arn : aws_iam_role.lambda_role[0].arn
  runtime       = "python3.9"
}

output "lambda_function_arn" {
  value = aws_lambda_function.this.arn
}
