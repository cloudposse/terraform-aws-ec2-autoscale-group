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


locals {
  default_ec2_alarms = {
    cpu_high = {
      alarm_name          = "${module.this.id}${module.this.delimiter}cpu${module.this.delimiter}utilization${module.this.delimiter}high"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = var.cpu_utilization_high_evaluation_periods
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = var.cpu_utilization_high_period_seconds
      statistic           = var.cpu_utilization_high_statistic
      threshold           = var.cpu_utilization_high_threshold_percent
      dimensions_name     = "AutoScalingGroupName"
      dimensions_target   = join("", aws_autoscaling_group.default.*.name)
      alarm_description   = "Scale up if CPU utilization is above ${var.cpu_utilization_high_threshold_percent} for ${var.cpu_utilization_high_period_seconds} seconds"
      alarm_actions       = [join("", aws_autoscaling_policy.scale_up.*.arn)]
    },
    cpu_low = {
      alarm_name          = "${module.this.id}${module.this.delimiter}cpu${module.this.delimiter}utilization${module.this.delimiter}low"
      comparison_operator = "LessThanOrEqualToThreshold"
      evaluation_periods  = var.cpu_utilization_low_evaluation_periods
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = var.cpu_utilization_low_period_seconds
      statistic           = var.cpu_utilization_low_statistic
      threshold           = var.cpu_utilization_low_threshold_percent
      dimensions_name     = "AutoScalingGroupName"
      dimensions_target   = join("", aws_autoscaling_group.default.*.name)
      alarm_description   = "Scale down if the CPU utilization is below ${var.cpu_utilization_low_threshold_percent} for ${var.cpu_utilization_low_period_seconds} seconds"
      alarm_actions       = [join("", aws_autoscaling_policy.scale_down.*.arn)]
    }
  }
  default_alarms = var.default_alarms_enabled ? local.default_ec2_alarms : {}
  all_alarms     = merge(var.custom_alarms, local.default_alarms)
}

resource "aws_cloudwatch_metric_alarm" "all_alarms" {
  for_each                  = module.this.enabled ? local.all_alarms : null
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