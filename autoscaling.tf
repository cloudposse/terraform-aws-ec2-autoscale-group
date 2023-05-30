# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ec2-metricscollected.html
locals {
  autoscaling_enabled = module.this.enabled && var.autoscaling_policies_enabled
}

resource "aws_autoscaling_policy" "scale_up" {
  count                  = local.autoscaling_enabled ? 1 : 0
  name                   = "${module.this.id}${module.this.delimiter}scale${module.this.delimiter}up"
  scaling_adjustment     = var.scale_up_scaling_adjustment
  adjustment_type        = var.scale_up_adjustment_type
  policy_type            = var.scale_up_policy_type
  cooldown               = var.scale_up_cooldown_seconds
  autoscaling_group_name = one(aws_autoscaling_group.default[*].name)
}

resource "aws_autoscaling_policy" "scale_down" {
  count                  = local.autoscaling_enabled ? 1 : 0
  name                   = "${module.this.id}${module.this.delimiter}scale${module.this.delimiter}down"
  scaling_adjustment     = var.scale_down_scaling_adjustment
  adjustment_type        = var.scale_down_adjustment_type
  policy_type            = var.scale_down_policy_type
  cooldown               = var.scale_down_cooldown_seconds
  autoscaling_group_name = one(aws_autoscaling_group.default[*].name)
}

locals {
  default_ec2_alarms = {
    cpu_high = {
      alarm_name                = "${module.this.id}${module.this.delimiter}cpu${module.this.delimiter}utilization${module.this.delimiter}high"
      comparison_operator       = "GreaterThanOrEqualToThreshold"
      evaluation_periods        = var.cpu_utilization_high_evaluation_periods
      metric_name               = "CPUUtilization"
      namespace                 = "AWS/EC2"
      period                    = var.cpu_utilization_high_period_seconds
      statistic                 = var.cpu_utilization_high_statistic
      extended_statistic        = null
      threshold                 = var.cpu_utilization_high_threshold_percent
      dimensions_name           = "AutoScalingGroupName"
      dimensions_target         = one(aws_autoscaling_group.default[*].name)
      alarm_description         = "Scale up if CPU utilization is above ${var.cpu_utilization_high_threshold_percent} for ${var.cpu_utilization_high_period_seconds} * ${var.cpu_utilization_high_evaluation_periods} seconds"
      alarm_actions             = [one(aws_autoscaling_policy.scale_up[*].arn)]
      treat_missing_data        = "missing"
      ok_actions                = []
      insufficient_data_actions = []
    },
    cpu_low = {
      alarm_name                = "${module.this.id}${module.this.delimiter}cpu${module.this.delimiter}utilization${module.this.delimiter}low"
      comparison_operator       = "LessThanOrEqualToThreshold"
      evaluation_periods        = var.cpu_utilization_low_evaluation_periods
      metric_name               = "CPUUtilization"
      namespace                 = "AWS/EC2"
      period                    = var.cpu_utilization_low_period_seconds
      statistic                 = var.cpu_utilization_low_statistic
      extended_statistic        = null
      threshold                 = var.cpu_utilization_low_threshold_percent
      dimensions_name           = "AutoScalingGroupName"
      dimensions_target         = one(aws_autoscaling_group.default[*].name)
      alarm_description         = "Scale down if the CPU utilization is below ${var.cpu_utilization_low_threshold_percent} for ${var.cpu_utilization_low_period_seconds} * ${var.cpu_utilization_high_evaluation_periods} seconds"
      alarm_actions             = [one(aws_autoscaling_policy.scale_down[*].arn)]
      treat_missing_data        = "missing"
      ok_actions                = []
      insufficient_data_actions = []
    }
  }

  default_alarms = var.autoscaling_policies_enabled && var.default_alarms_enabled ? local.default_ec2_alarms : {}
  all_alarms     = module.this.enabled ? merge(local.default_alarms, var.custom_alarms) : {}
}

resource "aws_cloudwatch_metric_alarm" "all_alarms" {
  for_each                  = local.all_alarms
  alarm_name                = format("%s%s", "${module.this.id}${module.this.delimiter}", each.value.alarm_name)
  comparison_operator       = each.value.comparison_operator
  evaluation_periods        = each.value.evaluation_periods
  metric_name               = each.value.metric_name
  namespace                 = each.value.namespace
  period                    = each.value.period
  statistic                 = each.value.statistic
  extended_statistic        = each.value.extended_statistic
  threshold                 = each.value.threshold
  treat_missing_data        = each.value.treat_missing_data
  ok_actions                = each.value.ok_actions
  insufficient_data_actions = each.value.insufficient_data_actions
  dimensions = {
    (each.value.dimensions_name) = (each.value.dimensions_target)
  }

  alarm_description = each.value.alarm_description
  alarm_actions     = each.value.alarm_actions
  tags              = var.tags
}
