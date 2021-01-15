# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ec2-metricscollected.html

locals {
  autoscaling_enabled = module.this.enabled && var.autoscaling_policies_enabled ? true : false
}

resource "aws_autoscaling_policy" "scale_up" {
  count                  = local.autoscaling_enabled ? 1 : 0
  name                   = "${module.this.id}${module.this.delimiter}scale${module.this.delimiter}up"
  scaling_adjustment     = var.scale_up_scaling_adjustment
  adjustment_type        = var.scale_up_adjustment_type
  policy_type            = var.scale_up_policy_type
  cooldown               = var.scale_up_cooldown_seconds
  autoscaling_group_name = join("", aws_autoscaling_group.default.*.name)
}

resource "aws_autoscaling_policy" "scale_down" {
  count                  = local.autoscaling_enabled ? 1 : 0
  name                   = "${module.this.id}${module.this.delimiter}scale${module.this.delimiter}down"
  scaling_adjustment     = var.scale_down_scaling_adjustment
  adjustment_type        = var.scale_down_adjustment_type
  policy_type            = var.scale_down_policy_type
  cooldown               = var.scale_down_cooldown_seconds
  autoscaling_group_name = join("", aws_autoscaling_group.default.*.name)
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count               = local.autoscaling_enabled ? 1 : 0
  alarm_name          = "${module.this.id}${module.this.delimiter}cpu${module.this.delimiter}utilization${module.this.delimiter}high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.cpu_utilization_high_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.cpu_utilization_high_period_seconds
  statistic           = var.cpu_utilization_high_statistic
  threshold           = var.cpu_utilization_high_threshold_percent

  dimensions = {
    AutoScalingGroupName = join("", aws_autoscaling_group.default.*.name)
  }

  alarm_description = "Scale up if CPU utilization is above ${var.cpu_utilization_high_threshold_percent} for ${var.cpu_utilization_high_period_seconds} seconds"
  alarm_actions     = [join("", aws_autoscaling_policy.scale_up.*.arn)]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  count               = local.autoscaling_enabled ? 1 : 0
  alarm_name          = "${module.this.id}${module.this.delimiter}cpu${module.this.delimiter}utilization${module.this.delimiter}low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.cpu_utilization_low_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.cpu_utilization_low_period_seconds
  statistic           = var.cpu_utilization_low_statistic
  threshold           = var.cpu_utilization_low_threshold_percent

  dimensions = {
    AutoScalingGroupName = join("", aws_autoscaling_group.default.*.name)
  }

  alarm_description = "Scale down if the CPU utilization is below ${var.cpu_utilization_low_threshold_percent} for ${var.cpu_utilization_low_period_seconds} seconds"
  alarm_actions     = [join("", aws_autoscaling_policy.scale_down.*.arn)]
}

resource "aws_cloudwatch_metric_alarm" "custom_alarms" {
  for_each                  = module.this.enabled ? var.custom_alarms : {}
  alarm_name                = format("%s%s", "${module.this.id}${module.this.delimiter}", each.value.alarm_name)
  comparison_operator       = lookup(each.value, "comparison_operator", null)
  evaluation_periods        = lookup(each.value, "evaluation_periods", null)
  metric_name               = lookup(each.value, "metric_name", null)
  namespace                 = lookup(each.value, "namespace", null)
  period                    = lookup(each.value, "period", null)
  statistic                 = lookup(each.value, "statistic", null)
  threshold                 = lookup(each.value, "threshold", null)
  treat_missing_data        = lookup(each.value, "treat_missing_data", null)
  ok_actions                = lookup(each.value, "ok_actions", null)
  insufficient_data_actions = lookup(each.value, "insufficient_data_actions", null)
  dimensions = {
    lookup(each.value, "dimensions_name", null) = lookup(each.value, "dimensions_target", null)
  }

  alarm_description = lookup(each.value, "alarm_description", null)
  alarm_actions     = [join("", aws_autoscaling_policy.scale_down.*.arn)]
}

variable "custom_alarms" {
  type = map(object({
    alarm_name                = string
    comparison_operator       = string
    evaluation_periods        = string
    metric_name               = string
    namespace                 = string
    period                    = string
    statistic                 = string
    threshold                 = string
    treat_missing_data        = string
    ok_actions                = list(string)
    insufficient_data_actions = list(string)
    dimensions_name           = string
    dimensions_target         = string
    alarm_description         = string
    alarm_actions             = list(string)
  }))
  default = {
    alarm_name                = null
    comparison_operator       = null
    evaluation_periods        = null
    metric_name               = null
    namespace                 = null
    period                    = null
    statistic                 = null
    threshold                 = null
    treat_missing_data        = null
    ok_actions                = []
    insufficient_data_actions = []
    dimensions_name           = null
    dimensions_target         = null
    alarm_description         = null
    alarm_actions             = []
  }
  description = "List of custom CloudWatch alarms configurations"
}