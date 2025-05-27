provider "aws" {
  region = var.aws_region
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "smart-resource-monitor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy_attachment" "lambda_attach" {
  name       = "lambda-basic-attach"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "sns_attach" {
  name       = "lambda-sns-attach"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

resource "aws_iam_policy_attachment" "ec2_attach" {
  name       = "lambda-ec2-attach"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "rds_attach" {
  name       = "lambda-rds-attach"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess"
}

resource "aws_sns_topic" "resource_alerts" {
  name = "smart-resource-monitor-topic"
}

resource "aws_lambda_function" "monitor_function" {
  filename         = "${path.module}/../lambda/function.zip"
  function_name    = "smart-resource-monitor"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/../lambda/function.zip")
  runtime          = "python3.12"

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.resource_alerts.arn
    }
  }
}

resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name                = "DailySmartResourceCheck"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_trigger.name
  target_id = "lambdaMonitor"
  arn       = aws_lambda_function.monitor_function.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.monitor_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
}
