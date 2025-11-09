output "sagemaker_notebook_name" {
  description = "SageMaker Notebook name"
  value       = aws_sagemaker_notebook_instance.free_tier_notebook.name
}

output "sagemaker_notebook_arn" {
  description = "SageMaker Notebook ARN"
  value       = aws_sagemaker_notebook_instance.free_tier_notebook.arn
}

output "iam_role_arn" {
  description = "IAM role ARN for SageMaker"
  value       = aws_iam_role.sagemaker_execution_role.arn
}
