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

variable "instance_market_options" {
  description = "The market (purchasing) option for the instances"

  type = object({
    market_type = string
    spot_options = object({
      block_duration_minutes         = number
      instance_interruption_behavior = string
      max_price                      = number
      spot_instance_type             = string
      valid_until                    = string
    })
  })

  default = null
}

variable mixed_instances_policy {
  description = "policy to used mixed group of on demand/spot of differing types. Launch template is automatically generated. https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html#mixed_instances_policy-1"

  type = object({
    instances_distribution = object({
      on_demand_allocation_strategy            = string
      on_demand_base_capacity                  = number
      on_demand_percentage_above_base_capacity = number
      spot_allocation_strategy                 = string
      spot_instance_pools                      = number
      spot_max_price                           = string
    })
    override = list(object({
      instance_type     = string
      weighted_capacity = number
    }))
  })
  default = null
}
