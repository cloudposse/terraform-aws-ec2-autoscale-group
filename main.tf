module "label" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=tags/0.1.6"
  namespace  = "${var.namespace}"
  name       = "${var.name}"
  stage      = "${var.stage}"
  delimiter  = "${var.delimiter}"
  attributes = "${var.attributes}"
  tags       = "${var.tags}"
  enabled    = "${var.enabled}"
}

resource "aws_launch_template" "default" {
  count = "${var.enabled == "true" ? 1 : 0}"

  name_prefix                          = "${format("%s%s", module.label.id, var.delimiter)}"
  block_device_mappings                = ["${var.block_device_mappings}"]
  credit_specification                 = ["${var.credit_specification}"]
  disable_api_termination              = "${var.disable_api_termination}"
  ebs_optimized                        = "${var.ebs_optimized}"
  elastic_gpu_specifications           = ["${var.elastic_gpu_specifications}"]
  image_id                             = "${var.image_id}"
  instance_initiated_shutdown_behavior = "${var.instance_initiated_shutdown_behavior}"
  instance_market_options              = ["${var.instance_market_options }"]
  instance_type                        = "${var.instance_type}"
  key_name                             = "${var.key_name}"
  placement                            = ["${var.placement}"]
  user_data                            = "${var.user_data_base64}"

  iam_instance_profile {
    name = "${var.iam_instance_profile_name}"
  }

  monitoring {
    enabled = "${var.enable_monitoring}"
  }

  # https://github.com/terraform-providers/terraform-provider-aws/issues/4570
  network_interfaces {
    description                 = "${module.label.id}"
    device_index                = 0
    associate_public_ip_address = "${var.associate_public_ip_address}"
    delete_on_termination       = true
    security_groups             = ["${var.security_group_ids}"]
  }

  tag_specifications {
    resource_type = "volume"
    tags          = "${module.label.tags}"
  }

  tag_specifications {
    resource_type = "instance"
    tags          = "${module.label.tags}"
  }

  tags = "${module.label.tags}"

  lifecycle {
    create_before_destroy = true
  }
}

data "null_data_source" "tags_as_list_of_maps" {
  count = "${var.enabled == "true" ? length(keys(var.tags)) : 0}"

  inputs = "${map(
    "key", "${element(keys(var.tags), count.index)}",
    "value", "${element(values(var.tags), count.index)}",
    "propagate_at_launch", true
  )}"
}

resource "aws_autoscaling_group" "default" {
  count = "${var.enabled == "true" && var.mixed_type == "false" ? 1 : 0}"

  name_prefix               = "${format("%s%s", module.label.id, var.delimiter)}"
  vpc_zone_identifier       = ["${var.subnet_ids}"]
  max_size                  = "${var.max_size}"
  min_size                  = "${var.min_size}"
  load_balancers            = ["${var.load_balancers}"]
  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type         = "${var.health_check_type}"
  min_elb_capacity          = "${var.min_elb_capacity}"
  wait_for_elb_capacity     = "${var.wait_for_elb_capacity}"
  target_group_arns         = ["${var.target_group_arns}"]
  default_cooldown          = "${var.default_cooldown}"
  force_delete              = "${var.force_delete}"
  termination_policies      = "${var.termination_policies}"
  suspended_processes       = "${var.suspended_processes}"
  placement_group           = "${var.placement_group}"
  enabled_metrics           = ["${var.enabled_metrics}"]
  metrics_granularity       = "${var.metrics_granularity}"
  wait_for_capacity_timeout = "${var.wait_for_capacity_timeout}"
  protect_from_scale_in     = "${var.protect_from_scale_in}"
  service_linked_role_arn   = "${var.service_linked_role_arn}"
  
  launch_template = {
    id      = "${join("", aws_launch_template.default.*.id)}"
    version = "${aws_launch_template.default.latest_version}"
  }

  tags = ["${data.null_data_source.tags_as_list_of_maps.*.outputs}"]

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "default_mixed" {
  count = "${var.enabled == "true" && var.mixed_type=="true" ? 1 : 0}"

  name_prefix               = "${format("%s%s", module.label.id, var.delimiter)}"
  vpc_zone_identifier       = ["${var.subnet_ids}"]
  max_size                  = "${var.max_size}"
  min_size                  = "${var.min_size}"
  load_balancers            = ["${var.load_balancers}"]
  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type         = "${var.health_check_type}"
  min_elb_capacity          = "${var.min_elb_capacity}"
  wait_for_elb_capacity     = "${var.wait_for_elb_capacity}"
  target_group_arns         = ["${var.target_group_arns}"]
  default_cooldown          = "${var.default_cooldown}"
  force_delete              = "${var.force_delete}"
  termination_policies      = "${var.termination_policies}"
  suspended_processes       = "${var.suspended_processes}"
  placement_group           = "${var.placement_group}"
  enabled_metrics           = ["${var.enabled_metrics}"]
  metrics_granularity       = "${var.metrics_granularity}"
  wait_for_capacity_timeout = "${var.wait_for_capacity_timeout}"
  protect_from_scale_in     = "${var.protect_from_scale_in}"
  service_linked_role_arn   = "${var.service_linked_role_arn}"
  

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = "${var.autoscaling_configs["on_demand_base_capacity"]}"
      on_demand_percentage_above_base_capacity = "${var.autoscaling_configs["on_demand_percentage_above_base_capacity"]}"
      spot_instance_pools                      = "${var.autoscaling_configs["spot_instance_pools"]}"
      spot_max_price                           = "${var.autoscaling_configs["spot_max_price"]}"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = "${join("", aws_launch_template.default.*.id)}"
      }
      override {
        instance_type = "${var.autoscaling_instances["supported_instance_1"]}"
      }

      override {
        instance_type = "${var.autoscaling_instances["supported_instance_2"]}"
      }

      override {
        instance_type = "${var.autoscaling_instances["supported_instance_3"]}"
      }
    }
  }

  tags = ["${data.null_data_source.tags_as_list_of_maps.*.outputs}"]

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      "launch_template",
      "mixed_instances_policy",
    ]
  }
}
