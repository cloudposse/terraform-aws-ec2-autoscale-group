locals {
  mip_override               = var.mixed_instances_policy != null ? lookup(var.mixed_instances_policy, "override", []) : []
  mip_override_instance_type = length(local.mip_override) > 0 ? var.mixed_instances_policy.override.*.instance_type : []
}

data "aws_ec2_instance_type" "ec2" {
  for_each      = toset(concat([var.instance_type], local.mip_override_instance_type))
  instance_type = each.key
}

locals {
  list_all_architectures_dirt = toset(compact(flatten([for k, v in data.aws_ec2_instance_type.ec2 : lookup(v, "supported_architectures", "")])))
  list_all_architectures      = [for v in local.list_all_architectures_dirt : v if v != "i386"]
  default_image_id_map        = length(var.image_id) > 0 ? { "${local.list_all_architectures[0]}" : var.image_id } : null
  image_id_map                = length(local.list_all_architectures) > 1 ? var.image_id_map : local.default_image_id_map
}

data "aws_ami" "amazon_linux2_auto" {
  for_each    = local.image_id_map == null ? local.list_all_architectures : toset([])
  most_recent = true
  owners      = ["amazon"]

  dynamic "filter" {
    for_each = merge(var.filter_for_image_id, { "architecture" = [each.key] })
    content {
      name   = filter.key
      values = filter.value
    }
  }

}

data "aws_ami" "image_definied" {
  for_each    = local.image_id_map != null ? local.image_id_map : {}
  most_recent = true

  filter {
    name   = "image-id"
    values = [each.value]
  }

}

locals {
  aws_ami      = merge(data.aws_ami.amazon_linux2_auto, data.aws_ami.image_definied)
  aws_ami_keys = keys(local.aws_ami)
  aws_ami_block_device_mappings = {
    for k, v in local.aws_ami :
    k => {
      device_name  = one(v.block_device_mappings.*.device_name)
      no_device    = one(v.block_device_mappings.*.no_device)
      virtual_name = one(v.block_device_mappings.*.virtual_name)
      ebs = {
        delete_on_termination = one(v.block_device_mappings.*.ebs.delete_on_termination)
        encrypted             = one(v.block_device_mappings.*.ebs.encrypted)
        iops                  = 3000
        kms_key_id            = null
        snapshot_id           = null
        throughput            = 125
        volume_size           = one(v.block_device_mappings.*.ebs.volume_size)
        volume_type           = "gp3"
      }
    }
  }
}

module "launch_template_label" {

  for_each = local.aws_ami

  source  = "cloudposse/label/null"
  version = "0.25.0" # requires Terraform >= 0.13.0

  attributes = [each.key]

  tags = {
    "Architecture" = each.key
  }

  context = module.this.context
}

resource "aws_launch_template" "default" {
  for_each = module.this.enabled ? local.aws_ami : {}

  name_prefix = format(
    "%s%s",
    module.launch_template_label[each.key].id,
    module.launch_template_label[each.key].delimiter
  )

  dynamic "block_device_mappings" {
    for_each = concat([local.aws_ami_block_device_mappings[each.key]], var.block_device_mappings)
    content {
      device_name  = lookup(block_device_mappings.value, "device_name", null)
      no_device    = lookup(block_device_mappings.value, "no_device", null)
      virtual_name = lookup(block_device_mappings.value, "virtual_name", null)

      dynamic "ebs" {
        for_each = lookup(block_device_mappings.value, "ebs", null) == null ? [] : ["ebs"]
        content {
          delete_on_termination = lookup(block_device_mappings.value.ebs, "delete_on_termination", null)
          encrypted             = lookup(block_device_mappings.value.ebs, "encrypted", null)
          iops                  = lookup(block_device_mappings.value.ebs, "iops", null)
          kms_key_id            = lookup(block_device_mappings.value.ebs, "kms_key_id", null)
          snapshot_id           = lookup(block_device_mappings.value.ebs, "snapshot_id", null)
          throughput            = lookup(block_device_mappings.value.ebs, "throughput", null)
          volume_size           = lookup(block_device_mappings.value.ebs, "volume_size", null)
          volume_type           = lookup(block_device_mappings.value.ebs, "volume_type", null)
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
  update_default_version  = var.update_default_version

  dynamic "elastic_gpu_specifications" {
    for_each = var.elastic_gpu_specifications != null ? [var.elastic_gpu_specifications] : []
    content {
      type = lookup(elastic_gpu_specifications.value, "type", null)
    }
  }

  image_id                             = each.value.id
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

  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile_name != "" ? [var.iam_instance_profile_name] : []
    content {
      name = iam_instance_profile.value
    }
  }

  monitoring {
    enabled = var.enable_monitoring
  }

  # https://github.com/terraform-providers/terraform-provider-aws/issues/4570
  network_interfaces {
    description                 = module.launch_template_label[each.key].id
    device_index                = 0
    associate_public_ip_address = var.associate_public_ip_address
    delete_on_termination       = true
    security_groups             = var.security_group_ids
  }

  metadata_options {
    http_endpoint               = (var.metadata_http_endpoint_enabled) ? "enabled" : "disabled"
    http_put_response_hop_limit = var.metadata_http_put_response_hop_limit
    http_tokens                 = (var.metadata_http_tokens_required) ? "required" : "optional"
    http_protocol_ipv6          = (var.metadata_http_protocol_ipv6_enabled) ? "enabled" : "disabled"
    instance_metadata_tags      = (var.metadata_instance_metadata_tags_enabled) ? "enabled" : "disabled"
  }

  dynamic "tag_specifications" {
    for_each = var.tag_specifications_resource_types

    content {
      resource_type = tag_specifications.value
      tags          = module.launch_template_label[each.key].tags
    }
  }

  tags = module.launch_template_label[each.key].tags

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  launch_template_block = { for architecture in local.list_all_architectures : architecture => {
    id      = aws_launch_template.default[architecture].id
    version = var.launch_template_version != "" ? var.launch_template_version : aws_launch_template.default[architecture].latest_version
  } }
  launch_template = (var.mixed_instances_policy == null ? local.launch_template_block : null)
  mixed_instances_policy_override = var.mixed_instances_policy != null ? [for v in lookup(var.mixed_instances_policy, "override", []) : {
    instance_type     = v["instance_type"]
    weighted_capacity = v["weighted_capacity"]
    launch_template_specification = local.launch_template_block[
      reverse(sort(lookup(data.aws_ec2_instance_type.ec2[v["instance_type"]], "supported_architectures", tolist(local.list_all_architectures))))[0]
    ]
  }] : []
  mixed_instances_policy = (
    var.mixed_instances_policy == null ? null : {
      instances_distribution = var.mixed_instances_policy.instances_distribution
      launch_template        = local.launch_template_block[tolist(local.list_all_architectures)[0]]
      override               = local.mixed_instances_policy_override
  })
  tags = {
    for key, value in module.this.tags :
    key => value if value != "" && value != null
  }
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
  desired_capacity          = var.desired_capacity
  max_instance_lifetime     = var.max_instance_lifetime
  capacity_rebalance        = var.capacity_rebalance

  dynamic "instance_refresh" {
    for_each = (var.instance_refresh != null ? [var.instance_refresh] : [])

    content {
      strategy = instance_refresh.value.strategy
      dynamic "preferences" {
        for_each = (length(instance_refresh.value.preferences) > 0 ? [instance_refresh.value.preferences] : [])
        content {
          instance_warmup        = lookup(preferences.value, "instance_warmup", null)
          min_healthy_percentage = lookup(preferences.value, "min_healthy_percentage", null)
        }
      }
      triggers = instance_refresh.value.triggers
    }
  }

  dynamic "launch_template" {
    for_each = (local.launch_template != null ? local.launch_template : {})
    content {
      id      = launch_template.value.id
      version = launch_template.value.version
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
            launch_template_specification {
              launch_template_id = lookup((lookup(override.value, "launch_template_specification", null)), "id", null)
              version            = lookup(lookup(override.value, "launch_template_specification", null), "version", null)
            }
          }
        }
      }
    }
  }

  dynamic "warm_pool" {
    for_each = var.warm_pool != null ? [var.warm_pool] : []
    content {
      pool_state                  = try(warm_pool.value.pool_state, null)
      min_size                    = try(warm_pool.value.min_size, null)
      max_group_prepared_capacity = try(warm_pool.value.max_group_prepared_capacity, null)
      dynamic "instance_reuse_policy" {
        for_each = var.instance_reuse_policy != null ? [var.instance_reuse_policy] : []
        content {
          reuse_on_scale_in = instance_reuse_policy.value.reuse_on_scale_in
        }
      }
    }
  }

  dynamic "tag" {
    for_each = local.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}
