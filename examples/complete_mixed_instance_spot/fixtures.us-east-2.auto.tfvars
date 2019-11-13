region = "us-east-2"

availability_zones = ["us-east-2a", "us-east-2b"]

namespace = "eg"

stage = "test"

name = "ec2-autoscale-group"

image_id = "ami-00c03f7f7f2ec15c3"

instance_type = "t2.small"

health_check_type = "EC2"

wait_for_capacity_timeout = "10m"

max_size = 3

min_size = 2

cpu_utilization_high_threshold_percent = 80

cpu_utilization_low_threshold_percent = 20

//
mixed_type = "true"
mixedspot_instance_distribution = {
  on_demand_base_capacity                  = 0
  spot_instance_pools                      = 1
  health_check_grace_period                = 60
  on_demand_percentage_above_base_capacity = 10
  spot_max_price                           = ""
}

mixedspot_instance_types = ["t3.medium", "t2.medium","t3.large" ]
