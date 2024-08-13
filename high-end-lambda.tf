

# Create an SNS Topic
resource "aws_sns_topic" "change_to_high_end_target_group" {
  name = join("-", [var.environ, "change-to-high-end-target-group"])
}

resource "aws_lambda_function" "change_to_high_end_target_group" {
  filename         = "${path.module}/change_target_group.zip"
  function_name    = join("-", [var.environ, "change_to_high_end_target_group"])
  role             = aws_iam_role.lambda_exec.arn
  handler          = "change_target_group.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("change_target_group.zip")

  environment {
    variables = {
      ALB_RULE_ARN     = var.alb_listener_group_arn
      TARGET_GROUP_ARN = var.high_end_target_group_arn
    }
  }

  tracing_config {
    mode = "Active"
  }
}

# Create a zip archive of the Lambda function code
data "archive_file" "change_target_group_zip" {
  type        = "zip"
  source_file = "change_target_group.py"
  output_path = "change_target_group.zip"
}


# Add SNS subscription for Lambda function
resource "aws_sns_topic_subscription" "high_end_lambda" {
  topic_arn = aws_sns_topic.change_to_high_end_target_group.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.change_to_high_end_target_group.arn
}

# Add the trigger in lambda
resource "aws_lambda_permission" "high_end_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.change_to_high_end_target_group.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.change_to_high_end_target_group.arn
}
