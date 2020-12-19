resource "aws_launch_template" "default" {
  count = module.this.enabled ? 1 : 0

  name_prefix = format("%s%s", module.this.id, module.this.delimiter)

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name  = lookup(block_device_mappings.value, "device_name", null)
      no_device    = lookup(block_device_mappings.value, "no_device", null)
      virtual_name = lookup(block_device_mappings.value, "virtual_name", null)

      dynamic "ebs" {
        for_each = flatten(list(lookup(block_device_mappings.value, "ebs", [])))
        content {
          delete_on_termination = lookup(ebs.value, "delete_on_termination", null)
          encrypted             = lookup(ebs.value, "encrypted", null)
          iops                  = lookup(ebs.value, "iops", null)
          kms_key_id            = lookup(ebs.value, "kms_key_id", null)
          snapshot_id           = lookup(ebs.value, "snapshot_id", null)
          volume_size           = lookup(ebs.value, "volume_size", null)
          volume_type           = lookup(ebs.value, "volume_type", null)
        }
      }
    }
  }

  dynamic "credit_specification" {
    for_each = var.credit_specification != null ? [var.credit_specification] : []
    content {
      cpu_credits = lookup(credit_specification.value, "cpu_credits", null)
    }
  }

  disable_api_termination = var.disable_api_termination
  ebs_optimized           = var.ebs_optimized

  dynamic "elastic_gpu_specifications" {
    for_each = var.elastic_gpu_specifications != null ? [var.elastic_gpu_specifications] : []
    content {
      type = lookup(elastic_gpu_specifications.value, "type", null)
    }
  }

  image_id                             = var.image_id
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior

  dynamic "instance_market_options" {
    for_each = var.instance_market_options != null ? [var.instance_market_options] : []
    content {
      market_type = lookup(instance_market_options.value, "market_type", null)

      dynamic "spot_options" {
        for_each = (instance_market_options.value.spot_options != null ?
        [instance_market_options.value.spot_options] : [])
        content {
          block_duration_minutes         = lookup(spot_options.value, "block_duration_minutes", null)
          instance_interruption_behavior = lookup(spot_options.value, "instance_interruption_behavior", null)
          max_price                      = lookup(spot_options.value, "max_price", null)
          spot_instance_type             = lookup(spot_options.value, "spot_instance_type", null)
          valid_until                    = lookup(spot_options.value, "valid_until", null)
        }
      }
    }
  }

  instance_type = var.instance_type
  key_name      = var.key_name

  dynamic "placement" {
    for_each = var.placement != null ? [var.placement] : []
    content {
      affinity          = lookup(placement.value, "affinity", null)
      availability_zone = lookup(placement.value, "availability_zone", null)
      group_name        = lookup(placement.value, "group_name", null)
      host_id           = lookup(placement.value, "host_id", null)
      tenancy           = lookup(placement.value, "tenancy", null)
    }
  }

  user_data = var.user_data_base64

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  monitoring {
    enabled = var.enable_monitoring
  }

  # https://github.com/terraform-providers/terraform-provider-aws/issues/4570
  network_interfaces {
    description                 = module.this.id
    device_index                = 0
    associate_public_ip_address = var.associate_public_ip_address
    delete_on_termination       = true
    security_groups             = var.security_group_ids
  }

  tag_specifications {
    resource_type = "volume"
    tags          = module.this.tags
  }

  tag_specifications {
    resource_type = "instance"
    tags          = module.this.tags
  }

  tags = module.this.tags

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  launch_template_block = {
    id      = join("", aws_launch_template.default.*.id)
    version = var.launch_template_version != "" ? var.launch_template_version : join("", aws_launch_template.default.*.latest_version)
  }
  launch_template = (
    var.mixed_instances_policy == null ? local.launch_template_block
  : null)
  mixed_instances_policy = (
    var.mixed_instances_policy == null ? null : {
      instances_distribution = var.mixed_instances_policy.instances_distribution
      launch_template        = local.launch_template_block
      override               = var.mixed_instances_policy.override
  })
}

resource "aws_autoscaling_group" "default" {
  count = module.this.enabled ? 1 : 0

  name_prefix               = format("%s%s", module.this.id, module.this.delimiter)
  vpc_zone_identifier       = var.subnet_ids
  max_size                  = var.max_size
  min_size                  = var.min_size
  load_balancers            = var.load_balancers
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  min_elb_capacity          = var.min_elb_capacity
  wait_for_elb_capacity     = var.wait_for_elb_capacity
  target_group_arns         = var.target_group_arns
  default_cooldown          = var.default_cooldown
  force_delete              = var.force_delete
  termination_policies      = var.termination_policies
  suspended_processes       = var.suspended_processes
  placement_group           = var.placement_group
  enabled_metrics           = var.enabled_metrics
  metrics_granularity       = var.metrics_granularity
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  protect_from_scale_in     = var.protect_from_scale_in
  service_linked_role_arn   = var.service_linked_role_arn

  dynamic "launch_template" {
    for_each = (local.launch_template != null ?
    [local.launch_template] : [])
    content {
      id      = local.launch_template_block.id
      version = local.launch_template_block.version
    }
  }

  dynamic "mixed_instances_policy" {
    for_each = (local.mixed_instances_policy != null ?
    [local.mixed_instances_policy] : [])
    content {
      dynamic "instances_distribution" {
        for_each = (
          mixed_instances_policy.value.instances_distribution != null ?
        [mixed_instances_policy.value.instances_distribution] : [])
        content {
          on_demand_allocation_strategy = lookup(
          instances_distribution.value, "on_demand_allocation_strategy", null)
          on_demand_base_capacity = lookup(
          instances_distribution.value, "on_demand_base_capacity", null)
          on_demand_percentage_above_base_capacity = lookup(
          instances_distribution.value, "on_demand_percentage_above_base_capacity", null)
          spot_allocation_strategy = lookup(
          instances_distribution.value, "spot_allocation_strategy", null)
          spot_instance_pools = lookup(
          instances_distribution.value, "spot_instance_pools", null)
          spot_max_price = lookup(
          instances_distribution.value, "spot_max_price", null)
        }
      }
      launch_template {
        launch_template_specification {
          launch_template_id = mixed_instances_policy.value.launch_template.id
          version            = mixed_instances_policy.value.launch_template.version
        }
        dynamic "override" {
          for_each = (mixed_instances_policy.value.override != null ?
          mixed_instances_policy.value.override : [])
          content {
            instance_type     = lookup(override.value, "instance_type", null)
            weighted_capacity = lookup(override.value, "weighted_capacity", null)
          }
        }
      }
    }
  }

  tags = flatten([
    for key in keys(module.this.tags) :
    {
      key                 = key
      value               = module.this.tags[key]
      propagate_at_launch = true
    }
  ])

  lifecycle {
    create_before_destroy = true
  }
}
