# S3 bucket to store SNS logs
resource "aws_s3_bucket" "site_bucket" {
  bucket = "storage-sns-sqs-${random_id.bucket_suffix.hex}"
  tags = {
    Name = "storage-sns-sqs-bucket"
    Env  = var.environment
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.site_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.site_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
# Upload the image
resource "aws_s3_object" "image" {
    bucket = aws_s3_bucket.site_bucket.id
    key    = "images/sample.jpg"
    source = "${path.module}/sample.jpg"
    content_type = "image/jpeg"
}

# Upload the index.html file from local directory (make sure index.html exists)
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.site_bucket.id
  key    = "index.html"
  source = "${path.module}/index.html"
  content_type = "text/html"
  etag = filemd5("${path.module}/index.html")
}


resource "aws_s3_bucket_policy" "public_access" {
  bucket = aws_s3_bucket.site_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.site_bucket.arn}/*"
      }
    ]
  })
}


# SNS topic
resource "aws_sns_topic" "s3_notifications" {
  name = "s3-upload-notification-topic"
}

# SNS email subscription (user must confirm the email)
resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.s3_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
  # Note: subscriber must confirm the subscription via the email sent by AWS.
}

# SQS queue
resource "aws_sqs_queue" "s3_queue" {
  name   = "s3-upload-events-queue"
 
}
resource "aws_cloudwatch_event_rule" "s3_object_created" {
  name        = "s3-object-created"
  description = "Trigger on S3 object creation"
  
  event_pattern = jsonencode({
    "source" : ["aws.s3"],
    "detail-type" : ["Object Created"],
    "detail" : {
      "bucket" : {
        "name" : [aws_s3_bucket.site_bucket.bucket]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "send_to_sns" {
  rule      = aws_cloudwatch_event_rule.s3_object_created.name
  target_id = "SNS"
  arn       = aws_sns_topic.s3_notifications.arn
}

resource "aws_cloudwatch_event_target" "send_to_sqs" {
  rule      = aws_cloudwatch_event_rule.s3_object_created.name
  target_id = "SQS"
  arn       = aws_sqs_queue.s3_queue.arn
}
resource "aws_sns_topic_policy" "allow_eventbridge" {
  arn    = aws_sns_topic.s3_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "events.amazonaws.com"
      }
      Action   = "sns:Publish"
      Resource = aws_sns_topic.s3_notifications.arn
    }]
  })
}
resource "aws_sqs_queue_policy" "allow_eventbridge" {
  queue_url = aws_sqs_queue.s3_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "events.amazonaws.com"
      }
      Action   = "sqs:SendMessage"
      Resource = aws_sqs_queue.s3_queue.arn
    }]
  })
}


# resource "aws_sqs_queue_policy" "s3_queue_policy" {
#   queue_url = aws_sqs_queue.s3_queue.id
#   policy    = data.aws_iam_policy_document.sqs_policy.json
# }


# S3 bucket notification configuration:
# - sends ObjectCreated:* events to SNS topic and SQS queue
# - enables EventBridge notifications for the bucket (eventbridge = true)
# resource "aws_s3_bucket_notification" "s3_notifications" {
#   bucket = aws_s3_bucket.site_bucket.id

#   depends_on = [
#     aws_sns_topic.s3_topic,
#     aws_sqs_queue_policy.s3_queue_policy
#   ]

#   topic {
#     topic_arn = aws_sns_topic.s3_topic.arn
#     events    = ["s3:ObjectCreated:*"]
#   }

#   queue {
#     queue_arn = aws_sqs_queue.s3_queue.arn
#     events    = ["s3:ObjectCreated:*"]
#   }
# }


