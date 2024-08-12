

# Create an SNS Topic
resource "aws_sns_topic" "change_to_low_end_target_group" {
  name = join("-", [var.environ, "change-to-low-end-target-group"])
}

resource "aws_lambda_function" "change_to_low_end_target_group" {
  filename         = "${path.module}/change_target_group.zip"
  function_name    = join("-", [var.environ, "change_to_low_end_target_group"])
  role             = aws_iam_role.lambda_exec.arn
  handler          = "change_target_group.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("change_target_group.zip")

  environment {
    variables = {
      ALB_RULE_ARN     = "arn:aws:elasticloadbalancing:ap-southeast-1:167814279506:listener-rule/app/dev-snap-backend-alb/c21aa16bac5be01e/48900cbbaa7b5068/332694db298a81fc"
      TARGET_GROUP_ARN = "arn:aws:elasticloadbalancing:ap-southeast-1:167814279506:targetgroup/low-end-node-tg/47eb294ec184ab68"
    }
  }

  tracing_config {
    mode = "Active"
  }
}

# Add SNS subscription for Lambda function
resource "aws_sns_topic_subscription" "low_end_lambda" {
  topic_arn = aws_sns_topic.change_to_low_end_target_group.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.change_to_low_end_target_group.arn
}

# Add the trigger in lambda
resource "aws_lambda_permission" "low_end_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.change_to_low_end_target_group.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.change_to_low_end_target_group.arn
}
