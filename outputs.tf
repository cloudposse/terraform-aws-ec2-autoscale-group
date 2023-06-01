output "launch_template_id" {
  description = "The ID of the launch template"
  value       = one(aws_launch_template.default[*].id)
}

output "launch_template_arn" {
  description = "The ARN of the launch template"
  value       = one(aws_launch_template.default[*].arn)
}

output "autoscaling_group_id" {
  description = "The AutoScaling Group id"
  value       = one(aws_autoscaling_group.default[*].id)
}

output "autoscaling_group_name" {
  description = "The AutoScaling Group name"
  value       = one(aws_autoscaling_group.default[*].name)
}

output "autoscaling_group_tags" {
  description = "A list of tag settings associated with the AutoScaling Group"
  value       = module.this.enabled ? aws_autoscaling_group.default[0].tag : []
}

output "autoscaling_group_arn" {
  description = "ARN of the AutoScaling Group"
  value       = one(aws_autoscaling_group.default[*].arn)
}

output "autoscaling_group_min_size" {
  description = "The minimum size of the autoscale group"
  value       = one(aws_autoscaling_group.default[*].min_size)
}

output "autoscaling_group_max_size" {
  description = "The maximum size of the autoscale group"
  value       = one(aws_autoscaling_group.default[*].max_size)
}

output "autoscaling_group_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  value       = one(aws_autoscaling_group.default[*].desired_capacity)
}

output "autoscaling_group_default_cooldown" {
  description = "Time between a scaling activity and the succeeding scaling activity"
  value       = one(aws_autoscaling_group.default[*].default_cooldown)
}

output "autoscaling_group_health_check_grace_period" {
  description = "Time after instance comes into service before checking health"
  value       = one(aws_autoscaling_group.default[*].health_check_grace_period)
}

output "autoscaling_group_health_check_type" {
  description = "`EC2` or `ELB`. Controls how health checking is done"
  value       = one(aws_autoscaling_group.default[*].health_check_type)
}

output "autoscaling_policy_scale_down_arn" {
  description = "ARN of the AutoScaling policy scale down"
  value       = one(aws_autoscaling_policy.scale_down[*].arn)
}

output "autoscaling_policy_scale_up_arn" {
  description = "ARN of the AutoScaling policy scale up"
  value       = one(aws_autoscaling_policy.scale_up[*].arn)
}
