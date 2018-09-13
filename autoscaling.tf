# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ec2-metricscollected.html

locals {
  autoscaling_policies_enabled = "${var.autoscaling_policies_enabled == "true" && var.enabled == "true" ? true : false}"
}

resource "aws_autoscaling_policy" "scale_up" {
  count                  = "${local.autoscaling_policies_enabled ? 1 : 0}"
  name                   = "${module.label.id}${var.delimiter}scale${var.delimiter}up"
  scaling_adjustment     = "${var.scale_up_scaling_adjustment}"
  adjustment_type        = "${var.scale_up_adjustment_type}"
  policy_type            = "${var.scale_up_policy_type}"
  cooldown               = "${var.scale_up_cooldown_seconds}"
  autoscaling_group_name = "${join("", aws_autoscaling_group.default.*.name)}"
}

resource "aws_autoscaling_policy" "scale_down" {
  count                  = "${local.autoscaling_policies_enabled ? 1 : 0}"
  name                   = "${module.label.id}${var.delimiter}scale${var.delimiter}down"
  scaling_adjustment     = "${var.scale_down_scaling_adjustment}"
  adjustment_type        = "${var.scale_down_adjustment_type}"
  policy_type            = "${var.scale_down_policy_type}"
  cooldown               = "${var.scale_down_cooldown_seconds}"
  autoscaling_group_name = "${join("", aws_autoscaling_group.default.*.name)}"
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  count               = "${local.autoscaling_policies_enabled ? 1 : 0}"
  alarm_name          = "${module.label.id}${var.delimiter}cpu${var.delimiter}reservation${var.delimiter}high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.high_cpu_evaluation_periods}"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "${var.high_cpu_period_seconds}"
  statistic           = "${var.high_cpu_statistic}"
  threshold           = "${var.high_cpu_threshold_percent}"

  dimensions {
    AutoScalingGroupName = "${join("", aws_autoscaling_group.default.*.name)}"
  }

  alarm_description = "Scale up if CPUUtilization is above ${var.high_cpu_threshold_percent} for ${var.high_cpu_period_seconds} seconds"
  alarm_actions     = ["${join("", aws_autoscaling_policy.scale_up.*.arn)}"]
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  count               = "${local.autoscaling_policies_enabled ? 1 : 0}"
  alarm_name          = "${module.label.id}${var.delimiter}cpu${var.delimiter}reservation${var.delimiter}low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "${var.low_cpu_evaluation_periods}"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "${var.low_cpu_period_seconds}"
  statistic           = "${var.low_cpu_statistic}"
  threshold           = "${var.low_cpu_threshold_percent}"

  dimensions {
    AutoScalingGroupName = "${join("", aws_autoscaling_group.default.*.name)}"
  }

  alarm_description = "Scale down if the CPUUtilization is below ${var.low_cpu_threshold_percent} for ${var.low_cpu_period_seconds} seconds"
  alarm_actions     = ["${join("", aws_autoscaling_policy.scale_down.*.arn)}"]
}
