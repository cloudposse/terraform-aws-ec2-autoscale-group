<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | >= 2.0 |
| null | >= 2.0 |
| template | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| this | cloudposse/label/null | 0.24.1 |

## Resources

| Name |
|------|
| [aws_autoscaling_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) |
| [aws_autoscaling_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) |
| [aws_cloudwatch_metric_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) |
| [aws_launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_tag\_map | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| associate\_public\_ip\_address | Associate a public IP address with an instance in a VPC | `bool` | `false` | no |
| attributes | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| autoscaling\_policies\_enabled | Whether to create `aws_autoscaling_policy` and `aws_cloudwatch_metric_alarm` resources to control Auto Scaling | `bool` | `true` | no |
| block\_device\_mappings | Specify volumes to attach to the instance besides the volumes specified by the AMI | <pre>list(object({<br>    device_name  = string<br>    no_device    = bool<br>    virtual_name = string<br>    ebs = object({<br>      delete_on_termination = bool<br>      encrypted             = bool<br>      iops                  = number<br>      kms_key_id            = string<br>      snapshot_id           = string<br>      volume_size           = number<br>      volume_type           = string<br>    })<br>  }))</pre> | `[]` | no |
| context | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| cpu\_utilization\_high\_evaluation\_periods | The number of periods over which data is compared to the specified threshold | `number` | `2` | no |
| cpu\_utilization\_high\_period\_seconds | The period in seconds over which the specified statistic is applied | `number` | `300` | no |
| cpu\_utilization\_high\_statistic | The statistic to apply to the alarm's associated metric. Either of the following is supported: `SampleCount`, `Average`, `Sum`, `Minimum`, `Maximum` | `string` | `"Average"` | no |
| cpu\_utilization\_high\_threshold\_percent | The value against which the specified statistic is compared | `number` | `90` | no |
| cpu\_utilization\_low\_evaluation\_periods | The number of periods over which data is compared to the specified threshold | `number` | `2` | no |
| cpu\_utilization\_low\_period\_seconds | The period in seconds over which the specified statistic is applied | `number` | `300` | no |
| cpu\_utilization\_low\_statistic | The statistic to apply to the alarm's associated metric. Either of the following is supported: `SampleCount`, `Average`, `Sum`, `Minimum`, `Maximum` | `string` | `"Average"` | no |
| cpu\_utilization\_low\_threshold\_percent | The value against which the specified statistic is compared | `number` | `10` | no |
| credit\_specification | Customize the credit specification of the instances | <pre>object({<br>    cpu_credits = string<br>  })</pre> | `null` | no |
| custom\_alarms | Map of custom CloudWatch alarms configurations | <pre>map(object({<br>    alarm_name                = string<br>    comparison_operator       = string<br>    evaluation_periods        = string<br>    metric_name               = string<br>    namespace                 = string<br>    period                    = string<br>    statistic                 = string<br>    threshold                 = string<br>    treat_missing_data        = string<br>    ok_actions                = list(string)<br>    insufficient_data_actions = list(string)<br>    dimensions_name           = string<br>    dimensions_target         = string<br>    alarm_description         = string<br>    alarm_actions             = list(string)<br>  }))</pre> | `{}` | no |
| default\_alarms\_enabled | Enable or disable cpu and memory Cloudwatch alarms | `bool` | `true` | no |
| default\_cooldown | The amount of time, in seconds, after a scaling activity completes before another scaling activity can start | `number` | `300` | no |
| delimiter | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| disable\_api\_termination | If `true`, enables EC2 Instance Termination Protection | `bool` | `false` | no |
| ebs\_optimized | If true, the launched EC2 instance will be EBS-optimized | `bool` | `false` | no |
| elastic\_gpu\_specifications | Specifications of Elastic GPU to attach to the instances | <pre>object({<br>    type = string<br>  })</pre> | `null` | no |
| enable\_monitoring | Enable/disable detailed monitoring | `bool` | `true` | no |
| enabled | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| enabled\_metrics | A list of metrics to collect. The allowed values are `GroupMinSize`, `GroupMaxSize`, `GroupDesiredCapacity`, `GroupInServiceInstances`, `GroupPendingInstances`, `GroupStandbyInstances`, `GroupTerminatingInstances`, `GroupTotalInstances` | `list(string)` | <pre>[<br>  "GroupMinSize",<br>  "GroupMaxSize",<br>  "GroupDesiredCapacity",<br>  "GroupInServiceInstances",<br>  "GroupPendingInstances",<br>  "GroupStandbyInstances",<br>  "GroupTerminatingInstances",<br>  "GroupTotalInstances"<br>]</pre> | no |
| environment | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| force\_delete | Allows deleting the autoscaling group without waiting for all instances in the pool to terminate. You can force an autoscaling group to delete even if it's in the process of scaling a resource. Normally, Terraform drains all the instances before deleting the group. This bypasses that behavior and potentially leaves resources dangling | `bool` | `false` | no |
| health\_check\_grace\_period | Time (in seconds) after instance comes into service before checking health | `number` | `300` | no |
| health\_check\_type | Controls how health checking is done. Valid values are `EC2` or `ELB` | `string` | `"EC2"` | no |
| iam\_instance\_profile\_name | The IAM instance profile name to associate with launched instances | `string` | `""` | no |
| id\_length\_limit | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| image\_id | The EC2 image ID to launch | `string` | `""` | no |
| instance\_initiated\_shutdown\_behavior | Shutdown behavior for the instances. Can be `stop` or `terminate` | `string` | `"terminate"` | no |
| instance\_market\_options | The market (purchasing) option for the instances | <pre>object({<br>    market_type = string<br>    spot_options = object({<br>      block_duration_minutes         = number<br>      instance_interruption_behavior = string<br>      max_price                      = number<br>      spot_instance_type             = string<br>      valid_until                    = string<br>    })<br>  })</pre> | `null` | no |
| instance\_refresh | The instance refresh definition | <pre>object({<br>    strategy = string<br>    preferences = object({<br>      instance_warmup        = number<br>      min_healthy_percentage = number<br>    })<br>    triggers = list(string)<br>  })</pre> | `null` | no |
| instance\_type | Instance type to launch | `string` | n/a | yes |
| key\_name | The SSH key name that should be used for the instance | `string` | `""` | no |
| label\_key\_case | The letter case of label keys (`tag` names) (i.e. `name`, `namespace`, `environment`, `stage`, `attributes`) to use in `tags`.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| label\_order | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | `null` | no |
| label\_value\_case | The letter case of output label values (also used in `tags` and `id`).<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Default value: `lower`. | `string` | `null` | no |
| launch\_template\_version | Launch template version. Can be version number, `$Latest` or `$Default` | `string` | `"$Latest"` | no |
| load\_balancers | A list of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers. For ALBs, use `target_group_arns` instead | `list(string)` | `[]` | no |
| max\_size | The maximum size of the autoscale group | `number` | n/a | yes |
| metrics\_granularity | The granularity to associate with the metrics to collect. The only valid value is 1Minute | `string` | `"1Minute"` | no |
| min\_elb\_capacity | Setting this causes Terraform to wait for this number of instances to show up healthy in the ELB only on creation. Updates will not wait on ELB instance number changes | `number` | `0` | no |
| min\_size | The minimum size of the autoscale group | `number` | n/a | yes |
| mixed\_instances\_policy | policy to used mixed group of on demand/spot of differing types. Launch template is automatically generated. https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html#mixed_instances_policy-1 | <pre>object({<br>    instances_distribution = object({<br>      on_demand_allocation_strategy            = string<br>      on_demand_base_capacity                  = number<br>      on_demand_percentage_above_base_capacity = number<br>      spot_allocation_strategy                 = string<br>      spot_instance_pools                      = number<br>      spot_max_price                           = string<br>    })<br>    override = list(object({<br>      instance_type     = string<br>      weighted_capacity = number<br>    }))<br>  })</pre> | `null` | no |
| name | Solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| namespace | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `null` | no |
| placement | The placement specifications of the instances | <pre>object({<br>    affinity          = string<br>    availability_zone = string<br>    group_name        = string<br>    host_id           = string<br>    tenancy           = string<br>  })</pre> | `null` | no |
| placement\_group | The name of the placement group into which you'll launch your instances, if any | `string` | `""` | no |
| protect\_from\_scale\_in | Allows setting instance protection. The autoscaling group will not select instances with this setting for terminination during scale in events | `bool` | `false` | no |
| regex\_replace\_chars | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| scale\_down\_adjustment\_type | Specifies whether the adjustment is an absolute number or a percentage of the current capacity. Valid values are `ChangeInCapacity`, `ExactCapacity` and `PercentChangeInCapacity` | `string` | `"ChangeInCapacity"` | no |
| scale\_down\_cooldown\_seconds | The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start | `number` | `300` | no |
| scale\_down\_policy\_type | The scalling policy type, either `SimpleScaling`, `StepScaling` or `TargetTrackingScaling` | `string` | `"SimpleScaling"` | no |
| scale\_down\_scaling\_adjustment | The number of instances by which to scale. `scale_down_scaling_adjustment` determines the interpretation of this number (e.g. as an absolute number or as a percentage of the existing Auto Scaling group size). A positive increment adds to the current capacity and a negative value removes from the current capacity | `number` | `-1` | no |
| scale\_up\_adjustment\_type | Specifies whether the adjustment is an absolute number or a percentage of the current capacity. Valid values are `ChangeInCapacity`, `ExactCapacity` and `PercentChangeInCapacity` | `string` | `"ChangeInCapacity"` | no |
| scale\_up\_cooldown\_seconds | The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start | `number` | `300` | no |
| scale\_up\_policy\_type | The scalling policy type, either `SimpleScaling`, `StepScaling` or `TargetTrackingScaling` | `string` | `"SimpleScaling"` | no |
| scale\_up\_scaling\_adjustment | The number of instances by which to scale. `scale_up_adjustment_type` determines the interpretation of this number (e.g. as an absolute number or as a percentage of the existing Auto Scaling group size). A positive increment adds to the current capacity and a negative value removes from the current capacity | `number` | `1` | no |
| security\_group\_ids | A list of associated security group IDs | `list(string)` | `[]` | no |
| service\_linked\_role\_arn | The ARN of the service-linked role that the ASG will use to call other AWS services | `string` | `""` | no |
| stage | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| subnet\_ids | A list of subnet IDs to launch resources in | `list(string)` | n/a | yes |
| suspended\_processes | A list of processes to suspend for the AutoScaling Group. The allowed values are `Launch`, `Terminate`, `HealthCheck`, `ReplaceUnhealthy`, `AZRebalance`, `AlarmNotification`, `ScheduledActions`, `AddToLoadBalancer`. Note that if you suspend either the `Launch` or `Terminate` process types, it can prevent your autoscaling group from functioning properly. | `list(string)` | `[]` | no |
| tags | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |
| target\_group\_arns | A list of aws\_alb\_target\_group ARNs, for use with Application Load Balancing | `list(string)` | `[]` | no |
| termination\_policies | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are `OldestInstance`, `NewestInstance`, `OldestLaunchConfiguration`, `ClosestToNextInstanceHour`, `Default` | `list(string)` | <pre>[<br>  "Default"<br>]</pre> | no |
| use\_name\_prefix | If `true`, this will use the asg argument `name_prefix` instead of `name` | `bool` | `true` | no |
| user\_data\_base64 | The Base64-encoded user data to provide when launching the instances | `string` | `""` | no |
| wait\_for\_capacity\_timeout | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior | `string` | `"10m"` | no |
| wait\_for\_elb\_capacity | Setting this will cause Terraform to wait for exactly this number of healthy instances in all attached load balancers on both create and update operations. Takes precedence over `min_elb_capacity` behavior | `number` | `0` | no |

## Outputs

| Name | Description |
|------|-------------|
| autoscaling\_group\_arn | ARN of the AutoScaling Group |
| autoscaling\_group\_default\_cooldown | Time between a scaling activity and the succeeding scaling activity |
| autoscaling\_group\_desired\_capacity | The number of Amazon EC2 instances that should be running in the group |
| autoscaling\_group\_health\_check\_grace\_period | Time after instance comes into service before checking health |
| autoscaling\_group\_health\_check\_type | `EC2` or `ELB`. Controls how health checking is done |
| autoscaling\_group\_id | The AutoScaling Group id |
| autoscaling\_group\_max\_size | The maximum size of the autoscale group |
| autoscaling\_group\_min\_size | The minimum size of the autoscale group |
| autoscaling\_group\_name | The AutoScaling Group name |
| launch\_template\_arn | The ARN of the launch template |
| launch\_template\_id | The ID of the launch template |
<!-- markdownlint-restore -->
