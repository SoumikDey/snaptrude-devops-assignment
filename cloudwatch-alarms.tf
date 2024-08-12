locals {
  asg_name = module.high_end_asg.autoscaling_group_name
}


#SCALE UP
resource "aws_autoscaling_policy" "scaling_up_policy" {
  name                   = "${var.queue_name}-dynamic-scaling-up-policy"
  policy_type            = "StepScaling"
  adjustment_type        = "ExactCapacity"
  autoscaling_group_name = local.asg_name
  enabled                = true


  step_adjustment {
    scaling_adjustment          = 1
    metric_interval_lower_bound = 0
    metric_interval_upper_bound = 5
  }
  step_adjustment {
    scaling_adjustment          = 2
    metric_interval_lower_bound = 5
  }
}


resource "aws_cloudwatch_metric_alarm" "sqs_messages_alarm_up" {
  alarm_name          = "${var.queue_name}-dynamic-scaling-up-CW-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "60"
  statistic           = "Average"
  threshold           = 5

  dimensions = {
    QueueName = var.queue_name
  }

  alarm_description = "Scales up High-end node ASG"
  alarm_actions     = [aws_autoscaling_policy.scaling_up_policy.arn, aws_sns_topic.change_to_high_end_target_group.arn ]
}

#SCALE DOWN
resource "aws_autoscaling_policy" "scaling_down_policy" {
  name                   = "${var.queue_name}-dynamic-scaling-down-policy"
  policy_type            = "StepScaling"
  adjustment_type        = "ExactCapacity"
  autoscaling_group_name = local.asg_name
  enabled                = true


  step_adjustment {
    scaling_adjustment          = 0
    metric_interval_lower_bound = 0
  }


}


resource "aws_cloudwatch_metric_alarm" "sqs_messages_alarm_down" {
  alarm_name          = "${var.queue_name}-dynamic-scaling-down-CW-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "60"
  statistic           = "Average"
  threshold           = 5

  dimensions = {
    QueueName = var.queue_name
  }

  alarm_description = "Scales down High-end node ASG"
  alarm_actions = [aws_autoscaling_policy.scaling_down_policy.arn]

}


resource "aws_cloudwatch_metric_alarm" "sqs_messages_alarm_down_change_tg" {
  alarm_name          = "${var.queue_name}-change-target-to-low-end"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "60"
  statistic           = "Average"
  threshold           = 5
  datapoints_to_alarm = 1

  dimensions = {
    QueueName = var.queue_name
  }

  alarm_description = "Change target group to Low end node ASG"
  alarm_actions     = [aws_sns_topic.change_to_low_end_target_group.arn]
}
