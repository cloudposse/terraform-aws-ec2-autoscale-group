provider "aws" {
  region = var.region
}

module "vpc" {
  source     = "cloudposse/vpc/aws"
  version    = "0.18.1"
  cidr_block = "172.16.0.0/16"

  context = module.this.context
}

module "subnets" {
  source               = "cloudposse/dynamic-subnets/aws"
  version              = "0.38.0"
  availability_zones   = var.availability_zones
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  cidr_block           = module.vpc.vpc_cidr_block
  nat_gateway_enabled  = false
  nat_instance_enabled = false

  context = module.this.context
}

module "autoscale_group" {
  source = "../../"

  image_id                      = var.image_id
  instance_type                 = var.instance_type
  instance_market_options       = var.instance_market_options
  mixed_instances_policy        = var.mixed_instances_policy
  subnet_ids                    = module.subnets.public_subnet_ids
  health_check_type             = var.health_check_type
  min_size                      = var.min_size
  max_size                      = var.max_size
  wait_for_capacity_timeout     = var.wait_for_capacity_timeout
  associate_public_ip_address   = true
  user_data_base64              = base64encode(local.userdata)
  metadata_http_tokens_required = true

  tags = {
    Tier              = "1"
    KubernetesCluster = "us-east-2.testing.cloudposse.co"
  }

  # Auto-scaling policies and CloudWatch metric alarms
  autoscaling_policies_enabled           = true
  cpu_utilization_high_threshold_percent = var.cpu_utilization_high_threshold_percent
  cpu_utilization_low_threshold_percent  = var.cpu_utilization_low_threshold_percent

  block_device_mappings = [
    {
      device_name  = "/dev/sdb"
      no_device    = null
      virtual_name = null
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 8
        volume_type           = "gp2"
        iops                  = null
        kms_key_id            = null
        snapshot_id           = null
      }
    }
  ]

  context = module.this.context
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
