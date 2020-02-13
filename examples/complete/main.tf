provider "aws" {
  region = var.region
}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.8.0"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  cidr_block = "172.16.0.0/16"
}

module "subnets" {
  source               = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.18.1"
  availability_zones   = var.availability_zones
  namespace            = var.namespace
  stage                = var.stage
  name                 = var.name
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  cidr_block           = module.vpc.vpc_cidr_block
  nat_gateway_enabled  = false
  nat_instance_enabled = false
}

module "autoscale_group" {
  source = "../../"

  namespace = var.namespace
  stage     = var.stage
  name      = var.name

  image_id                    = var.image_id
  instance_type               = var.instance_type
  instance_market_options     = var.instance_market_options
  mixed_instances_policy      = var.mixed_instances_policy
  subnet_ids                  = module.subnets.public_subnet_ids
  health_check_type           = var.health_check_type
  min_size                    = var.min_size
  max_size                    = var.max_size
  wait_for_capacity_timeout   = var.wait_for_capacity_timeout
  associate_public_ip_address = true
  user_data_base64            = base64encode(local.userdata)

  tags = {
    Tier              = "1"
    KubernetesCluster = "us-east-2.testing.cloudposse.co"
  }

  # Auto-scaling policies and CloudWatch metric alarms
  autoscaling_policies_enabled           = true
  cpu_utilization_high_threshold_percent = var.cpu_utilization_high_threshold_percent
  cpu_utilization_low_threshold_percent  = var.cpu_utilization_low_threshold_percent
}

# https://www.terraform.io/docs/configuration/expressions.html#string-literals
locals {
  userdata = <<-USERDATA
    #!/bin/bash
    cat <<"__EOF__" > /home/ec2-user/.ssh/config
    Host *
        StrictHostKeyChecking no
    __EOF__
    chmod 600 /home/ec2-user/.ssh/config
    chown ec2-user:ec2-user /home/ec2-user/.ssh/config
  USERDATA
}
