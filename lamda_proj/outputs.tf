output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.sns_logger.function_name
}

output "s3_bucket_name" {
  value = aws_s3_bucket.sns_logs.bucket
}
