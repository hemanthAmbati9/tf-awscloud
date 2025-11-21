# Get current account info
data "aws_caller_identity" "current" {}
# build SQS queue policy that allows S3 to send messages to this queue (and SNS optionally)
# data "aws_iam_policy_document" "sqs_policy" {
#   statement {
#     sid = "Allow-S3-SendMessage"
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["s3.amazonaws.com"]
#     }

#     actions = [
#       "sqs:SendMessage",
#       "sqs:SendMessageBatch"
#     ]

#     resources = [
#       aws_sqs_queue.s3_queue.arn
#     ]

#     condition {
#       test     = "ArnEquals"
#       variable = "aws:SourceArn"
#       values   = [aws_s3_bucket.site_bucket.arn]
#     }
#   }
# }