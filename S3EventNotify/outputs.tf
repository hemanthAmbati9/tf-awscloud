# (Optional) Allow S3 to publish to SNS — generally not required for SNS notifications,
# but some accounts/regions may require additional policy. Usually SNS is fine.
# If you need a policy, add additional statements here.

# Outputs
output "bucket_name" {
  value = aws_s3_bucket.site_bucket.id
}

output "sns_topic_arn" {
  value = aws_sns_topic.s3_notifications.arn
}

output "sqs_queue_url" {
  value = aws_sqs_queue.s3_queue.id
}

output "sqs_queue_arn" {
  value = aws_sqs_queue.s3_queue.arn
}