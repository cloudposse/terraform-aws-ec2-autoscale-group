variable "namespace" {
  type        = "string"
  default     = "eg"
  description = "Namespace, which could be your organization name, e.g. 'eg' or 'cp'"
}

variable "stage" {
  type        = "string"
  default     = "testing"
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
}

variable "environment" {
  type        = "string"
  default     = ""
  description = "Environment, e.g. 'testing', 'UAT'"
}

variable "name" {
  type        = "string"
  default     = "test"
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

variable "region" {
  type        = "string"
  default     = "us-west-2"
  description = "AWS Region"
}

variable "image_id" {
  type        = "string"
  default     = "ami-08cab282f9979fc7a"
  description = "The EC2 image ID to launch"
}

variable "instance_type" {
  type        = "string"
  default     = "t2.small"
  description = "Instance type to launch"
}

variable "health_check_type" {
  type        = "string"
  default     = "EC2"
  description = "Controls how health checking is done. Valid values are `EC2` or `ELB`"
}

variable "wait_for_capacity_timeout" {
  type        = "string"
  default     = "10m"
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior"
}

variable "max_size" {
  default     = 5
  description = "The maximum size of the autoscale group"
}

variable "min_size" {
  default     = 3
  description = "The minimum size of the autoscale group"
}

variable "cpu_utilization_high_threshold_percent" {
  type        = "string"
  default     = "80"
  description = "CPU utilization high threshold"
}

variable "cpu_utilization_low_threshold_percent" {
  type        = "string"
  default     = "20"
  description = "CPU utilization loq threshold"
}

variable "mixed_type" {
  type        = "string"
  default     = "true"
}

#https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html#instances_distribution
variable "autoscaling_configs" {
  default = {
      on_demand_base_capacity = 0
      spot_instance_pools = 1
      health_check_grace_period = 300
      on_demand_percentage_above_base_capacity = 10
      spot_max_price = ""
  }
}

variable "autoscaling_instances" {
  default = {
      supported_instance_1 = "t3.medium"
      supported_instance_2 = "t2.medium"
      supported_instance_3 = "t3.large"
  }
}