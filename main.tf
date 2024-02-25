provider "aws" {
  region = var.region
}

# Create a Lambda function using the OS-only runtime and my compiled source.
resource "aws_lambda_function" "go_lambda" {
  function_name = "go_CloudFront_invalidate"
  handler       = "bootstrap"
  role          = aws_iam_role.go_lambda_role.arn
  runtime       = "provided.al2"
  s3_bucket     = "blog-terraform-input-artifacts"
  s3_key        = "goInvalidateCacheNoRPC.zip"
}

# Create an IAM role for the Lambda function to use.
resource "aws_iam_role" "go_lambda_role" {
  name = "go_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
        Sid = ""
      },
    ]
  })
}

# Attach a policy to the IAM role to grant necessary permissions for Lambda.
resource "aws_iam_policy_attachment" "lambda_basic_execution_cloudfront_codepipeline" {
  for_each = toset([
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole", 
    "arn:aws:iam::aws:policy/CloudFrontFullAccess",
    "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
  ])
  name = "lambda_basic_execution_cloudfront_codepipeline"
  roles      = [aws_iam_role.go_lambda_role.name]
  policy_arn = each.value
}

