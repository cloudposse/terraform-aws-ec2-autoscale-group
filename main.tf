module "label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.5.3"
  namespace   = "${var.namespace}"
  name        = "${var.name}"
  stage       = "${var.stage}"
  environment = "${var.environment}"
  delimiter   = "${var.delimiter}"
  attributes  = "${var.attributes}"
  tags        = "${var.tags}"

  additional_tag_map = {
    propagate_at_launch = true
  }
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
  vpc_security_group_ids               = ["${var.security_group_ids}"]

  iam_instance_profile {
    name = "${var.iam_instance_profile_name}"
  }

  monitoring {
    enabled = "${var.enable_monitoring}"
  }

  network_interfaces {
    associate_public_ip_address = "${var.associate_public_ip_address}"
  }

  tag_specifications {
    resource_type = "volume"
    tags          = "${module.label.tags}"
  }

  tag_specifications {
    resource_type = "instance"
    tags          = "${module.label.tags}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "default" {
  count = "${var.enabled == "true" ? 1 : 0}"

  name_prefix               = "${format("%s%s", module.label.id, var.delimiter)}"
  vpc_zone_identifier       = ["${var.subnet_ids}"]
  max_size                  = "${var.max_size}"
  min_size                  = "${var.min_size}"
  desired_capacity          = "${var.desired_capacity > 0 ? var.desired_capacity : var.min_size}"
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
    version = "${var.launch_template_version}"
  }

  tags = ["${module.label.tags_as_list_of_maps}"]

  lifecycle {
    create_before_destroy = true
  }
}
