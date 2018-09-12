
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| associate_public_ip_address | Associate a public ip address with an instance in a VPC | string | `false` | no |
| attributes | Additional attributes (e.g. `1`) | list | `<list>` | no |
| autoscaling_group_enabled | Whether to create autoscaling group | string | `true` | no |
| default_cooldown | The amount of time, in seconds, after a scaling activity completes before another scaling activity can start | string | `300` | no |
| delimiter | Delimiter to be used between `name`, `namespace`, `stage`, etc. | string | `-` | no |
| desired_capacity | The number of Amazon EC2 instances that should be running in the group | string | - | yes |
| ebs_block_device | Additional EBS block devices to attach to the instance | list | `<list>` | no |
| ebs_optimized | If true, the launched EC2 instance will be EBS-optimized | string | `false` | no |
| enable_monitoring | Enables/disables detailed monitoring. This is enabled by default. | string | `true` | no |
| enabled_metrics | A list of metrics to collect. The allowed values are GroupMinSize, GroupMaxSize, GroupDesiredCapacity, GroupInServiceInstances, GroupPendingInstances, GroupStandbyInstances, GroupTerminatingInstances, GroupTotalInstances | list | `<list>` | no |
| environment | Environment, e.g. 'testing', 'UAT' | string | `` | no |
| ephemeral_block_device | Customize Ephemeral (also known as 'Instance Store') volumes on the instance | list | `<list>` | no |
| force_delete | Allows deleting the autoscaling group without waiting for all instances in the pool to terminate. You can force an autoscaling group to delete even if it's in the process of scaling a resource. Normally, Terraform drains all the instances before deleting the group. This bypasses that behavior and potentially leaves resources dangling | string | `false` | no |
| health_check_grace_period | Time (in seconds) after instance comes into service before checking health | string | `300` | no |
| health_check_type | Controls how health checking is done. Valid values are `EC2` or `ELB` | string | `EC2` | no |
| iam_instance_profile | The IAM instance profile to associate with launched instances | string | `` | no |
| image_id | The EC2 image ID to launch | string | `` | no |
| instance_type | Instance type to launch | string | `` | no |
| key_name | The SSH key name that should be used for the instance | string | `` | no |
| launch_configuration | The name of the existing launch configuration to use | string | `` | no |
| launch_configuration_enabled | Whether to create launch configuration | string | `true` | no |
| load_balancers | A list of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers. For ALBs, use `target_group_arns` instead | list | `<list>` | no |
| max_size | The maximum size of the autoscale group | string | - | yes |
| metrics_granularity | The granularity to associate with the metrics to collect. The only valid value is 1Minute | string | `1Minute` | no |
| min_elb_capacity | Setting this causes Terraform to wait for this number of instances to show up healthy in the ELB only on creation. Updates will not wait on ELB instance number changes | string | `0` | no |
| min_size | The minimum size of the autoscale group | string | - | yes |
| name | Solution name, e.g. 'app' or 'cluster' | string | `app` | no |
| namespace | Namespace, which could be your organization name, e.g. 'eg' or 'cp' | string | - | yes |
| placement_group | The name of the placement group into which you'll launch your instances, if any | string | `` | no |
| placement_tenancy | The tenancy of the instance. Valid values are 'default' or 'dedicated' | string | `default` | no |
| protect_from_scale_in | Allows setting instance protection. The autoscaling group will not select instances with this setting for terminination during scale in events | string | `false` | no |
| root_block_device | Customize details about the root block device of the instance | list | `<list>` | no |
| security_groups | A list of associated security group IDs | list | `<list>` | no |
| service_linked_role_arn | The ARN of the service-linked role that the ASG will use to call other AWS services | string | `` | no |
| spot_price | The price to use for reserving spot instances | string | `` | no |
| stage | Stage, e.g. 'prod', 'staging', 'dev', or 'test' | string | - | yes |
| subnet_ids | A list of subnet IDs to launch resources in | list | - | yes |
| suspended_processes | A list of processes to suspend for the AutoScaling Group. The allowed values are `Launch`, `Terminate`, `HealthCheck`, `ReplaceUnhealthy`, `AZRebalance`, `AlarmNotification`, `ScheduledActions`, `AddToLoadBalancer`. Note that if you suspend either the `Launch` or `Terminate` process types, it can prevent your autoscaling group from functioning properly. | list | `<list>` | no |
| tags | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | map | `<map>` | no |
| target_group_arns | A list of aws_alb_target_group ARNs, for use with Application Load Balancing | list | `<list>` | no |
| termination_policies | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are `OldestInstance`, `NewestInstance`, `OldestLaunchConfiguration`, `ClosestToNextInstanceHour`, `Default` | list | `<list>` | no |
| user_data_base64 | Used to pass base64-encoded binary data to the EC2 instances. For example, gzip-encoded user data must be base64-encoded and passed via this argument to avoid corruption | string | `` | no |
| wait_for_capacity_timeout | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior | string | `10m` | no |
| wait_for_elb_capacity | Setting this will cause Terraform to wait for exactly this number of healthy instances in all attached load balancers on both create and update operations. Takes precedence over min_elb_capacity behavior | string | `false` | no |

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
| launch_configuration_id | The ID of the launch configuration |
| launch_configuration_name | The name of the launch configuration |

