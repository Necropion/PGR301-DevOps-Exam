resource "aws_sqs_queue" "image_generation_queue" {
  name = "image-generation-queue"
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"
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
  filename         = "lambda_sqs.zip" # You should zip your `lambda_sqs.py` file and make it available in this location
  source_code_hash = filebase64sha256("lambda_sqs.zip")
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_sqs.lambda_handler"
  runtime          = "python3.9"
  timeout          = 30
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
  batch_size       = 10
  enabled          = true
}
