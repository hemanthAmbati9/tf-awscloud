
# S3 bucket to store SNS logs
resource "aws_s3_bucket" "sns_logs" {
  bucket = "lambda-sns-${random_id.bucket_suffix.hex}"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "expire-old-objects"
    enabled = true
    expiration {
      days = 365
    }
  }

  tags = {
    Name = "sns-logs-bucket"
    Env  = var.environment
  }
}
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.sns_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_name}-lambda-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
      }
    ]
  })
}

# IAM policy to allow writing to S3 and CloudWatch Logs
resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "${var.project_name}-lambda-s3-policy"
  description = "Allow Lambda to write SNS payloads to S3 and log to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:PutObjectTagging"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.sns_logs.arn}/*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "attach_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

# Also attach AWS managed policy for basic Lambda execution (CloudWatch)
resource "aws_iam_role_policy_attachment" "attach_managed_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}



# Lambda function
resource "aws_lambda_function" "sns_logger" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-sns-logger"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.10"
  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)

  timeout = 30
  memory_size = 128

  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.sns_logs.bucket
    }
  }

  tags = {
    Name = "sns-logger-lambda"
    Env  = var.environment
  }
}


# SNS topic
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-topic"

  tags = {
    Name = "sns-topic"
    Env  = var.environment
  }
}

# SNS subscription: Lambda
resource "aws_sns_topic_subscription" "lambda_sub" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.sns_logger.arn
}

# Grant SNS permission to invoke Lambda
resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sns_logger.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alerts.arn
}
# SNS subscription: Email (requires user to confirm via email)
resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}
