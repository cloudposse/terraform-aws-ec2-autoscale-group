region = "us-east-2"

availability_zones = ["us-east-2a", "us-east-2b"]

namespace = "eg"

stage = "test"

name = "ec2-autoscale-group"

instance_type = "t2.small"

health_check_type = "EC2"

wait_for_capacity_timeout = "10m"

max_size = 3

min_size = 2

cpu_utilization_high_threshold_percent = 80

cpu_utilization_low_threshold_percent = 20

mixed_instances_policy = {
  instances_distribution = {
    on_demand_allocation_strategy            = "prioritized"
    on_demand_base_capacity                  = 0
    on_demand_percentage_above_base_capacity = 0
    spot_allocation_strategy                 = "lowest-price"
    spot_instance_pools                      = 2
    spot_max_price                           = ""
  }
  override = [for v in sort(data.aws_ec2_instance_types.this.instance_types) : { instance_type = v, weighted_capacity = 1 }]
  override = [
    { instance_type = "t4g.small", weighted_capacity = 1 },
    { instance_type = "t3.small", weighted_capacity = 1 }
  ]
}