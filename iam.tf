# Create an IAM role for Lambda execution
resource "aws_iam_role" "lambda_exec" {
  name  = join("-", [var.environ, "sns-lambda-exec-role"])

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "sns_topic_full_access_policy" {
  name = join("-", [var.environ, "sns-topic-full-access-policy"])
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:*",
        ]
        Resource = "${aws_sns_topic.change_to_low_end_target_group.arn}"
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:ModifyRule",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:DeleteRule",
          "elasticloadbalancing:DeleteTargetGroup",
        ]
        Resource = "*"
      }
    ]
  })
}



# Attach policies to the Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_exec_policy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_exec.id
}

resource "aws_iam_role_policy_attachment" "lambda_sns_policy_attach" {
  role       = aws_iam_role.lambda_exec.id
  policy_arn = aws_iam_policy.sns_topic_full_access_policy.arn
}