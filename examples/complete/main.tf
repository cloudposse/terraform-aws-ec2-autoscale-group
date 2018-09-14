provider "aws" {
  region = "us-west-2"
}

locals {
  userdata = <<USERDATA
    #!/bin/bash
    cat <<"__EOF__" > /home/ec2-user/.ssh/config
    Host *
        StrictHostKeyChecking no
    __EOF__
    chmod 600 /home/ec2-user/.ssh/config
    chown ec2-user:ec2-user /home/ec2-user/.ssh/config
  USERDATA
}

module "autoscale_group" {
  source = "git::https://github.com/cloudposse/terraform-aws-ec2-autoscale-group.git?ref=master"

  namespace = "eg"
  stage     = "dev"
  name      = "test"

  image_id                    = "ami-08cab282f9979fc7a"
  instance_type               = "t2.small"
  security_group_ids          = ["sg-xxxxxxxx"]
  subnet_ids                  = ["subnet-xxxxxxxx", "subnet-yyyyyyyy", "subnet-zzzzzzzz"]
  health_check_type           = "EC2"
  min_size                    = 2
  max_size                    = 3
  wait_for_capacity_timeout   = "5m"
  associate_public_ip_address = true
  user_data_base64            = "${base64encode(local.userdata)}"

  tags = {
    Tier              = "1"
    KubernetesCluster = "us-west-2.testing.cloudposse.co"
  }

  # Auto-scaling policies and CloudWatch metric alarms
  autoscaling_policies_enabled           = "true"
  cpu_utilization_high_threshold_percent = "70"
  cpu_utilization_low_threshold_percent  = "20"
}
