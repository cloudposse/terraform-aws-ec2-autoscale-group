variable "namespace" {
  type        = "string"
  description = "Namespace, which could be your organization name, e.g. 'eg' or 'cp'"
}

variable "stage" {
  type        = "string"
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
}

variable "environment" {
  type        = "string"
  default     = ""
  description = "Environment, e.g. 'testing', 'UAT'"
}

variable "name" {
  default     = "app"
  description = "Solution name, e.g. 'app' or 'cluster'"
}

variable "delimiter" {
  type        = "string"
  default     = "-"
  description = "Delimiter to be used between `name`, `namespace`, `stage`, etc."
}

variable "attributes" {
  type        = "list"
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
}

variable "launch_configuration_enabled" {
  description = "Whether to create launch configuration"
  default     = "true"
}

variable "existing_launch_configuration_name" {
  description = "The name of the existing launch configuration to use"
  default     = ""
}

variable "autoscaling_group_enabled" {
  description = "Whether to create autoscaling group"
  default     = "true"
}

variable "image_id" {
  description = "The EC2 image ID to launch"
  default     = ""
}

variable "instance_type" {
  description = "Instance type to launch"
  default     = ""
}

variable "iam_instance_profile" {
  description = "The IAM instance profile to associate with launched instances"
  default     = ""
}

variable "key_name" {
  description = "The SSH key name that should be used for the instance"
  default     = ""
}

variable "security_groups" {
  description = "A list of associated security group IDs"
  type        = "list"
  default     = []
}

variable "associate_public_ip_address" {
  description = "Associate a public ip address with an instance in a VPC"
  default     = false
}

variable "user_data_base64" {
  description = "Used to pass base64-encoded binary data to the EC2 instances. For example, gzip-encoded user data must be base64-encoded and passed via this argument to avoid corruption"
  default     = ""
}

variable "enable_monitoring" {
  description = "Enables/disables detailed monitoring. This is enabled by default."
  default     = true
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  default     = false
}

variable "root_block_device_volume_type" {
  description = "The type of the root volume. Can be `standard`, `gp2` or `io1`"
  type        = "string"
  default     = "gp2"
}

variable "root_block_device_volume_size" {
  description = "The size of the root volume in gigabytes"
  type        = "string"
  default     = "20"
}

variable "root_block_device_iops" {
  description = "The amount of provisioned IOPS for the root volume. This must be set with a volume_type of `io1`"
  default     = 0
}

variable "root_block_device_delete_on_termination" {
  description = " Whether the root volume should be destroyed on instance termination"
  default     = true
}

variable "ebs_block_device" {
  description = "Additional EBS block devices to attach to the instance"
  type        = "list"
  default     = []
}

variable "ephemeral_block_device" {
  description = "Customize Ephemeral (also known as 'Instance Store') volumes on the instance"
  type        = "list"
  default     = []
}

variable "spot_price" {
  description = "The price to use for reserving spot instances"
  default     = ""
}

variable "placement_tenancy" {
  description = "The tenancy of the instance. Valid values are 'default' or 'dedicated'"
  default     = "default"
}

variable "max_size" {
  description = "The maximum size of the autoscale group"
}

variable "min_size" {
  description = "The minimum size of the autoscale group"
}

variable "desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group. If set to 0, the value will be taken from the `min_size` variable"
  default     = 0
}

variable "subnet_ids" {
  description = "A list of subnet IDs to launch resources in"
  type        = "list"
}

variable "default_cooldown" {
  description = "The amount of time, in seconds, after a scaling activity completes before another scaling activity can start"
  default     = 300
}

variable "health_check_grace_period" {
  description = "Time (in seconds) after instance comes into service before checking health"
  default     = 300
}

variable "health_check_type" {
  description = "Controls how health checking is done. Valid values are `EC2` or `ELB`"
  default     = "EC2"
}

variable "force_delete" {
  description = "Allows deleting the autoscaling group without waiting for all instances in the pool to terminate. You can force an autoscaling group to delete even if it's in the process of scaling a resource. Normally, Terraform drains all the instances before deleting the group. This bypasses that behavior and potentially leaves resources dangling"
  default     = false
}

variable "load_balancers" {
  type        = "list"
  description = "A list of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers. For ALBs, use `target_group_arns` instead"
  default     = []
}

variable "target_group_arns" {
  type        = "list"
  description = "A list of aws_alb_target_group ARNs, for use with Application Load Balancing"
  default     = []
}

variable "termination_policies" {
  description = "A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are `OldestInstance`, `NewestInstance`, `OldestLaunchConfiguration`, `ClosestToNextInstanceHour`, `Default`"
  type        = "list"
  default     = ["Default"]
}

variable "suspended_processes" {
  type        = "list"
  description = "A list of processes to suspend for the AutoScaling Group. The allowed values are `Launch`, `Terminate`, `HealthCheck`, `ReplaceUnhealthy`, `AZRebalance`, `AlarmNotification`, `ScheduledActions`, `AddToLoadBalancer`. Note that if you suspend either the `Launch` or `Terminate` process types, it can prevent your autoscaling group from functioning properly."
  default     = []
}

variable "placement_group" {
  description = "The name of the placement group into which you'll launch your instances, if any"
  default     = ""
}

variable "metrics_granularity" {
  description = "The granularity to associate with the metrics to collect. The only valid value is 1Minute"
  default     = "1Minute"
}

variable "enabled_metrics" {
  description = "A list of metrics to collect. The allowed values are `GroupMinSize`, `GroupMaxSize`, `GroupDesiredCapacity`, `GroupInServiceInstances`, `GroupPendingInstances`, `GroupStandbyInstances`, `GroupTerminatingInstances`, `GroupTotalInstances`"
  type        = "list"

  default = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]
}

variable "wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior"
  default     = "10m"
}

variable "min_elb_capacity" {
  description = "Setting this causes Terraform to wait for this number of instances to show up healthy in the ELB only on creation. Updates will not wait on ELB instance number changes"
  default     = 0
}

variable "wait_for_elb_capacity" {
  description = "Setting this will cause Terraform to wait for exactly this number of healthy instances in all attached load balancers on both create and update operations. Takes precedence over `min_elb_capacity` behavior"
  default     = false
}

variable "protect_from_scale_in" {
  description = "Allows setting instance protection. The autoscaling group will not select instances with this setting for terminination during scale in events"
  default     = false
}

variable "service_linked_role_arn" {
  description = "The ARN of the service-linked role that the ASG will use to call other AWS services"
  default     = ""
}
