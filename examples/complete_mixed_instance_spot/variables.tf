variable "namespace" {
  type        = string
  description = "Namespace, which could be your organization name, e.g. 'eg' or 'cp'"
}

variable "stage" {
  type        = string
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
}

variable "name" {
  type        = string
  description = "Solution name, e.g. 'app' or 'cluster'"
}

variable "region" {
  type        = string
  description = "AWS Region"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "image_id" {
  type        = string
  description = "The EC2 image ID to launch"
}

variable "instance_type" {
  type        = string
  description = "Instance type to launch"
}

variable "health_check_type" {
  type        = string
  description = "Controls how health checking is done. Valid values are `EC2` or `ELB`"
}

variable "wait_for_capacity_timeout" {
  type        = string
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior"
}

variable "max_size" {
  type        = number
  description = "The maximum size of the autoscale group"
}

variable "min_size" {
  type        = number
  description = "The minimum size of the autoscale group"
}

variable "cpu_utilization_high_threshold_percent" {
  type        = number
  description = "CPU utilization high threshold"
}

variable "cpu_utilization_low_threshold_percent" {
  type        = number
  description = "CPU utilization low threshold"
}


// Mixed Type Autoscale
variable "mixedspot_asg" {
  description = "Enabled Mixed Instance Policy AutoScaling"
  type    = string
  default = "true"
}
#https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html#instances_distribution
variable "mixedspot_instance_distribution" {
  type = object({
    on_demand_base_capacity                  = number
    spot_instance_pools                      = number
    health_check_grace_period                = number
    on_demand_percentage_above_base_capacity = number
    spot_max_price                           = string
  })
  default = {
    on_demand_base_capacity                  = 0
    spot_instance_pools                      = 1
    health_check_grace_period                = 300
    on_demand_percentage_above_base_capacity = 10
    spot_max_price                           = ""
  }
}

variable "mixedspot_instance_types" {
  description = "Instance Size to use for mixed-type spot requests"

  type = list(string)
  default = []
}
