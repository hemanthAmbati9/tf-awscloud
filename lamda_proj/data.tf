# Get account ID for log ARNs
data "aws_caller_identity" "current" {}

# Package the Lambda (use local file content to zip)
data "local_file" "lambda_code" {
  filename = "${path.module}/lambda_function.py"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = data.local_file.lambda_code.filename
  output_path = "${path.module}/lambda_function.zip"
}
