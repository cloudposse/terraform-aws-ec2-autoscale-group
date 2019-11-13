module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.15.0"
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags
  enabled    = var.enabled
}

resource "aws_launch_template" "default" {
  count = var.enabled ? 1 : 0

  name_prefix = format("%s%s", module.label.id, var.delimiter)

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
        for_each = flatten(list(lookup(instance_market_options.value, "spot_options", [])))
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
    description                 = module.label.id
    device_index                = 0
    associate_public_ip_address = var.associate_public_ip_address
    delete_on_termination       = true
    security_groups             = var.security_group_ids
  }

  tag_specifications {
    resource_type = "volume"
    tags          = module.label.tags
  }

  tag_specifications {
    resource_type = "instance"
    tags          = module.label.tags
  }

  tags = module.label.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "default" {
  count = var.enabled && ! var.mixedspot_asg ? 1 : 0

  name_prefix               = format("%s%s", module.label.id, var.delimiter)
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

  launch_template {
    id      = join("", aws_launch_template.default.*.id)
    version = var.launch_template_version != "" ? var.launch_template_version : join("", aws_launch_template.default.*.latest_version)
  }

  tags = flatten([
    for key in keys(module.label.tags) :
    {
      key                 = key
      value               = module.label.tags[key]
      propagate_at_launch = true
    }
  ])

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "default_mixed" {
  count = var.enabled && var.mixedspot_asg ? 1 : 0

  name_prefix               = format("%s%s", module.label.id, var.delimiter)
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

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = var.mixedspot_instance_distribution["on_demand_base_capacity"]
      on_demand_percentage_above_base_capacity = var.mixedspot_instance_distribution["on_demand_percentage_above_base_capacity"]
      spot_instance_pools                      = var.mixedspot_instance_distribution["spot_instance_pools"]
      spot_max_price                           = var.mixedspot_instance_distribution["spot_max_price"]
    }

    launch_template {
      launch_template_specification {
        launch_template_id = join("", aws_launch_template.default.*.id)
        version            = var.launch_template_version != "" ? var.launch_template_version : join("", aws_launch_template.default.*.latest_version)
      }

      dynamic "override" {
        for_each = var.mixedspot_instance_types
        content {
          instance_type = override.value
        }
      }
    }
  }


  tags = flatten([
    for key in keys(module.label.tags) :
    {
      key                 = key
      value               = module.label.tags[key]
      propagate_at_launch = true
    }
  ])

  lifecycle {
    create_before_destroy = true
  }
}
