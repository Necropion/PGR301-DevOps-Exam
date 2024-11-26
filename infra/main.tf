resource "aws_sqs_queue" "image_generation_queue" {
  name = "image-generation-queue"
  message_retention_seconds = 300
  visibility_timeout_seconds = 55
  delay_seconds              = 0
  max_message_size           = 262144
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role_candidate_74"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name   = "sqs_lambda_policy"
    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "sqs:ReceiveMessage",
            "sqs:DeleteMessage",
            "sqs:GetQueueAttributes"
          ],
          "Resource": "${aws_sqs_queue.image_generation_queue.arn}"
        },
        {
          "Effect": "Allow",
          "Action": "s3:PutObject",
          "Resource": "arn:aws:s3:::pgr301-couch-explorers/*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "bedrock:InvokeModel"
          ],
          "Resource": "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-image-generator-v1"
        }
      ]
    })
  }
}

resource "aws_lambda_function" "image_processor" {
  function_name    = "image_processor_lambda-74"
  filename         = "lambda_sqs.zip"
  source_code_hash = filebase64sha256("lambda_sqs.zip")
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_sqs.lambda_handler"
  runtime          = "python3.9"
  timeout          = 30
  reserved_concurrent_executions = 1
  environment {
    variables = {
      BUCKET_NAME     = "pgr301-couch-explorers"
      CANDIDATE_NUMBER = "74"
    }
  }

  depends_on = [aws_iam_role.lambda_execution_role]
}

resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.image_generation_queue.arn
  function_name    = aws_lambda_function.image_processor.arn
  batch_size       = 100
  maximum_batching_window_in_seconds = 10
  enabled          = true
}

variable "notification_email" {
  description = "The email address to receive CloudWatch alarm notifications"
  type        = string
}

resource "aws_sns_topic" "alarm_notifications" {
  name = "sqs-alarm-notifications"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alarm_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_cloudwatch_metric_alarm" "sqs_oldest_message_age_alarm" {
  alarm_name          = "SQSApproximateAgeOfOldestMessageAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 1
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  statistic           = "Maximum"
  period              = 10
  alarm_description   = "Alarm when the oldest message in SQS is older than 5 minutes."
  actions_enabled     = true

  alarm_actions = [aws_sns_topic.alarm_notifications.arn]

  dimensions = {
    QueueName = aws_sqs_queue.image_generation_queue.name
  }
}

output "sns_topic_arn" {
  value       = aws_sns_topic.alarm_notifications.arn
  description = "The ARN of the SNS topic for alarm notifications"
}
