
# --- IAM role for SageMaker ---
resource "aws_iam_role" "sagemaker_execution_role" {
  name = "tfsagemaker-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "sagemaker.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach basic permissions for S3, CloudWatch Logs (Free Tier safe)
resource "aws_iam_role_policy_attachment" "sagemaker_s3_access" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "sagemaker_logs_access" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# --- SageMaker Notebook Instance (Free Tier) ---
resource "aws_sagemaker_notebook_instance" "free_tier_notebook" {
  name               = "free-tier-notebook"
  instance_type      = "ml.t2.medium"  # Free tier eligible
  role_arn           = aws_iam_role.sagemaker_execution_role.arn
  direct_internet_access = "Enabled"

  tags = {
    Environment = "dev"
    Name        = "FreeTierSageMakerNotebook"
  }
}
