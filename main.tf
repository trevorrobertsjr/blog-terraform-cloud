provider "aws" {
  region = var.region
}

resource "aws_lambda_function" "example_lambda" {
  function_name = "go_CloudFront_invalidate"
  handler       = "bootstrap"  # Update this based on your runtime and entry point.
  role          = aws_iam_role.example_lambda_role.arn  # Ensure you have a role with appropriate permissions.
  runtime       = "provided.al2023"  # Replace with the correct runtime identifier.
  s3_bucket     = "blog-terraform-input-artifacts"
  s3_key        = "goInvalidateCacheNoRPC.zip"

  # Optionally, specify the S3 object version if you want to use a specific version of the ZIP file
  # s3_object_version = "your-object-version"

  source_code_hash = filebase64sha256("goInvalidateCacheNoRPC.zip")  # For local ZIP file checksum. Update the path as necessary.
}

resource "aws_iam_role" "example_lambda_role" {
  name = "example_lambda_role"

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

# Attach a policy to the IAM role to grant necessary permissions for Lambda
resource "aws_iam_policy_attachment" "lambda_basic_execution_cloudfront_codepipeline" {
  for_each = toset([
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole", 
    "arn:aws:iam::aws:policy/CloudFrontFullAccess",
    "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
  ])
  roles      = [aws_iam_role.example_lambda_role.name]
  policy_arn = each.value
}

