region = "us-east-2"

availability_zones = ["us-east-2a", "us-east-2b"]

namespace = "eg"

stage = "test"

name = "ec2-autoscale-group"

image_id = "ami-0182f373e66f89c85"

instance_type = "t2.small"

health_check_type = "EC2"

wait_for_capacity_timeout = "10m"

max_size = 3

min_size = 2

cpu_utilization_high_threshold_percent = 80

cpu_utilization_low_threshold_percent = 20
