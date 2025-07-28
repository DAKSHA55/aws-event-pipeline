provider "aws" {
  region = "ap-south-1" # Mumbai
}

resource "aws_s3_bucket" "input_bucket" {
  bucket = "csv-input-bucket-kshitij"
}

resource "aws_s3_bucket" "output_bucket" {
  bucket = "csv-output-bucket-kshitij"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/function.zip"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role_v2"  # or any unique name
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

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#  NEW POLICY for S3 read/write access
resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "lambda-s3-access"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = [
          "arn:aws:s3:::csv-input-bucket-kshitij/*",
          "arn:aws:s3:::csv-output-bucket-kshitij/*"
        ]
      }
    ]
  })
}

resource "aws_lambda_function" "csv_processor" {
  function_name    = "csvProcessorFunction"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 30
}

resource "aws_s3_bucket_notification" "s3_trigger" {
  bucket = aws_s3_bucket.input_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.csv_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.csv_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.input_bucket.arn
}
