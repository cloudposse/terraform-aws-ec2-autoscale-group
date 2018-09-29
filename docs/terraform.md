
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| associate_public_ip_address | Associate a public IP address with an instance in a VPC | string | `false` | no |
| attributes | Additional attributes (e.g. `1`) | list | `<list>` | no |
| autoscaling_policies_enabled | Whether to create `aws_autoscaling_policy` and `aws_cloudwatch_metric_alarm` resources to control Auto Scaling | string | `true` | no |
| block_device_mappings | Specify volumes to attach to the instance besides the volumes specified by the AMI | list | `<list>` | no |
| cpu_utilization_high_evaluation_periods | The number of periods over which data is compared to the specified threshold | string | `2` | no |
| cpu_utilization_high_period_seconds | The period in seconds over which the specified statistic is applied | string | `300` | no |
| cpu_utilization_high_statistic | The statistic to apply to the alarm's associated metric. Either of the following is supported: `SampleCount`, `Average`, `Sum`, `Minimum`, `Maximum` | string | `Average` | no |
| cpu_utilization_high_threshold_percent | The value against which the specified statistic is compared | string | `90` | no |
| cpu_utilization_low_evaluation_periods | The number of periods over which data is compared to the specified threshold | string | `2` | no |
| cpu_utilization_low_period_seconds | The period in seconds over which the specified statistic is applied | string | `300` | no |
| cpu_utilization_low_statistic | The statistic to apply to the alarm's associated metric. Either of the following is supported: `SampleCount`, `Average`, `Sum`, `Minimum`, `Maximum` | string | `Average` | no |
| cpu_utilization_low_threshold_percent | The value against which the specified statistic is compared | string | `10` | no |
| credit_specification | Customize the credit specification of the instances | list | `<list>` | no |
| default_cooldown | The amount of time, in seconds, after a scaling activity completes before another scaling activity can start | string | `300` | no |
| delimiter | Delimiter to be used between `name`, `namespace`, `stage`, etc. | string | `-` | no |
| disable_api_termination | If `true`, enables EC2 Instance Termination Protection | string | `false` | no |
| ebs_optimized | If true, the launched EC2 instance will be EBS-optimized | string | `false` | no |
| elastic_gpu_specifications | Specifications of Elastic GPU to attach to the instances | list | `<list>` | no |
| enable_monitoring | Enable/disable detailed monitoring | string | `true` | no |
| enabled | Whether to create the resources. Set to `false` to prevent the module from creating any resources | string | `true` | no |
| enabled_metrics | A list of metrics to collect. The allowed values are `GroupMinSize`, `GroupMaxSize`, `GroupDesiredCapacity`, `GroupInServiceInstances`, `GroupPendingInstances`, `GroupStandbyInstances`, `GroupTerminatingInstances`, `GroupTotalInstances` | list | `<list>` | no |
| environment | Environment, e.g. 'testing', 'UAT' | string | `` | no |
| force_delete | Allows deleting the autoscaling group without waiting for all instances in the pool to terminate. You can force an autoscaling group to delete even if it's in the process of scaling a resource. Normally, Terraform drains all the instances before deleting the group. This bypasses that behavior and potentially leaves resources dangling | string | `false` | no |
| health_check_grace_period | Time (in seconds) after instance comes into service before checking health | string | `300` | no |
| health_check_type | Controls how health checking is done. Valid values are `EC2` or `ELB` | string | `EC2` | no |
| iam_instance_profile_name | The IAM instance profile name to associate with launched instances | string | `` | no |
| image_id | The EC2 image ID to launch | string | `` | no |
| instance_initiated_shutdown_behavior | Shutdown behavior for the instances. Can be `stop` or `terminate` | string | `terminate` | no |
| instance_market_options | The market (purchasing) option for the instances | list | `<list>` | no |
| instance_type | Instance type to launch | string | - | yes |
| key_name | The SSH key name that should be used for the instance | string | `` | no |
| launch_template_version | Launch template version. Can be version number, `$Latest` or `$Default` | string | `$Latest` | no |
| load_balancers | A list of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers. For ALBs, use `target_group_arns` instead | list | `<list>` | no |
| max_size | The maximum size of the autoscale group | string | - | yes |
| metrics_granularity | The granularity to associate with the metrics to collect. The only valid value is 1Minute | string | `1Minute` | no |
| min_elb_capacity | Setting this causes Terraform to wait for this number of instances to show up healthy in the ELB only on creation. Updates will not wait on ELB instance number changes | string | `0` | no |
| min_size | The minimum size of the autoscale group | string | - | yes |
| name | Solution name, e.g. 'app' or 'cluster' | string | `app` | no |
| namespace | Namespace, which could be your organization name, e.g. 'eg' or 'cp' | string | - | yes |
| placement | The placement specifications of the instances | list | `<list>` | no |
| placement_group | The name of the placement group into which you'll launch your instances, if any | string | `` | no |
| protect_from_scale_in | Allows setting instance protection. The autoscaling group will not select instances with this setting for terminination during scale in events | string | `false` | no |
| scale_down_adjustment_type | Specifies whether the adjustment is an absolute number or a percentage of the current capacity. Valid values are `ChangeInCapacity`, `ExactCapacity` and `PercentChangeInCapacity` | string | `ChangeInCapacity` | no |
| scale_down_cooldown_seconds | The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start | string | `300` | no |
| scale_down_policy_type | The scalling policy type, either `SimpleScaling`, `StepScaling` or `TargetTrackingScaling` | string | `SimpleScaling` | no |
| scale_down_scaling_adjustment | The number of instances by which to scale. `scale_down_scaling_adjustment` determines the interpretation of this number (e.g. as an absolute number or as a percentage of the existing Auto Scaling group size). A positive increment adds to the current capacity and a negative value removes from the current capacity | string | `-1` | no |
| scale_up_adjustment_type | Specifies whether the adjustment is an absolute number or a percentage of the current capacity. Valid values are `ChangeInCapacity`, `ExactCapacity` and `PercentChangeInCapacity` | string | `ChangeInCapacity` | no |
| scale_up_cooldown_seconds | The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start | string | `300` | no |
| scale_up_policy_type | The scalling policy type, either `SimpleScaling`, `StepScaling` or `TargetTrackingScaling` | string | `SimpleScaling` | no |
| scale_up_scaling_adjustment | The number of instances by which to scale. `scale_up_adjustment_type` determines the interpretation of this number (e.g. as an absolute number or as a percentage of the existing Auto Scaling group size). A positive increment adds to the current capacity and a negative value removes from the current capacity | string | `1` | no |
| security_group_ids | A list of associated security group IDs | list | `<list>` | no |
| service_linked_role_arn | The ARN of the service-linked role that the ASG will use to call other AWS services | string | `` | no |
| stage | Stage, e.g. 'prod', 'staging', 'dev', or 'test' | string | - | yes |
| subnet_ids | A list of subnet IDs to launch resources in | list | - | yes |
| suspended_processes | A list of processes to suspend for the AutoScaling Group. The allowed values are `Launch`, `Terminate`, `HealthCheck`, `ReplaceUnhealthy`, `AZRebalance`, `AlarmNotification`, `ScheduledActions`, `AddToLoadBalancer`. Note that if you suspend either the `Launch` or `Terminate` process types, it can prevent your autoscaling group from functioning properly. | list | `<list>` | no |
| tags | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | map | `<map>` | no |
| target_group_arns | A list of aws_alb_target_group ARNs, for use with Application Load Balancing | list | `<list>` | no |
| termination_policies | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are `OldestInstance`, `NewestInstance`, `OldestLaunchConfiguration`, `ClosestToNextInstanceHour`, `Default` | list | `<list>` | no |
| user_data_base64 | The Base64-encoded user data to provide when launching the instances | string | `` | no |
| wait_for_capacity_timeout | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior | string | `10m` | no |
| wait_for_elb_capacity | Setting this will cause Terraform to wait for exactly this number of healthy instances in all attached load balancers on both create and update operations. Takes precedence over `min_elb_capacity` behavior | string | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| autoscaling_group_arn | The ARN for this AutoScaling Group |
| autoscaling_group_default_cooldown | Time between a scaling activity and the succeeding scaling activity |
| autoscaling_group_desired_capacity | The number of Amazon EC2 instances that should be running in the group |
| autoscaling_group_health_check_grace_period | Time after instance comes into service before checking health |
| autoscaling_group_health_check_type | `EC2` or `ELB`. Controls how health checking is done |
| autoscaling_group_id | The autoscaling group id |
| autoscaling_group_max_size | The maximum size of the autoscale group |
| autoscaling_group_min_size | The minimum size of the autoscale group |
| autoscaling_group_name | The autoscaling group name |
| launch_template_arn | The ARN of the launch template |
| launch_template_id | The ID of the launch template |

