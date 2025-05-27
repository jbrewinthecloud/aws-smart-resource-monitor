output "lambda_function_name" {
  value = aws_lambda_function.monitor_function.function_name
}

output "sns_topic_arn" {
  value = aws_sns_topic.resource_alerts.arn
}
