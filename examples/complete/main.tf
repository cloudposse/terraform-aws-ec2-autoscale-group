provider "aws" {
  region = "us-west-2"
}

module "autoscale_group" {
  source = "git::https://github.com/cloudposse/terraform-aws-ec2-autoscale-group.git?ref=master"

  namespace = "eg"
  stage     = "dev"
  name      = "test"

  image_id                    = "ami-08cab282f9979fc7a"
  instance_type               = "t2.small"
  security_groups             = ["sg-xxxxxxxx"]
  subnet_ids                  = ["subnet-xxxxxxxx", "subnet-yyyyyyyy", "subnet-zzzzzzzz"]
  health_check_type           = "EC2"
  min_size                    = 1
  max_size                    = 3
  desired_capacity            = 2
  wait_for_capacity_timeout   = "5m"
  associate_public_ip_address = true

  root_block_device = [
    {
      volume_type           = "gp2"
      volume_size           = "20"
      delete_on_termination = true
    },
  ]

  ebs_block_device = [
    {
      device_name           = "/dev/xvdd"
      volume_type           = "gp2"
      volume_size           = "100"
      delete_on_termination = true
    },
  ]
}
