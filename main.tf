provider "aws" {
  region = "ap-south-1"  # Change if you're in a different region
}

# Input S3 Bucket
resource "aws_s3_bucket" "input_bucket" {
  bucket        = "csv-input-bucket-kshitij"
  force_destroy = true
}

# Output S3 Bucket
resource "aws_s3_bucket" "output_bucket" {
  bucket        = "csv-output-bucket-kshitij"
  force_destroy = true
}

# Lambda IAM Role
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })
}

# Attach basic Lambda execution policy
resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = "attach-lambda-basic"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function
resource "aws_lambda_function" "csv_processor" {
  filename         = "function.zip"
  function_name    = "csvProcessorFunction"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("function.zip")
  timeout          = 10

  environment {
    variables = {
      OUTPUT_BUCKET = aws_s3_bucket.output_bucket.bucket
    }
  }

  depends_on = [
    aws_iam_policy_attachment.lambda_basic_execution
  ]
}

# Allow S3 to invoke Lambda
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.csv_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.input_bucket.arn
}

# S3 Notification to trigger Lambda
resource "aws_s3_bucket_notification" "input_bucket_notification" {
  bucket = aws_s3_bucket.input_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.csv_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}
