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
    "propagate_at_launch" = "true"
  }
}

resource "aws_launch_configuration" "default" {
  count = "${var.launch_configuration_enabled == "true" ? 1: 0}"

  name_prefix                 = "${format("%s%s", module.label.id, var.delimiter)}"
  image_id                    = "${var.image_id}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${var.iam_instance_profile}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${var.security_groups}"]
  associate_public_ip_address = "${var.associate_public_ip_address}"
  user_data_base64            = "${var.user_data_base64}"
  enable_monitoring           = "${var.enable_monitoring}"
  ebs_optimized               = "${var.ebs_optimized}"
  root_block_device           = "${var.root_block_device}"
  ebs_block_device            = "${var.ebs_block_device}"
  ephemeral_block_device      = "${var.ephemeral_block_device}"
  spot_price                  = "${var.spot_price}"
  placement_tenancy           = "${var.spot_price == "" ? var.placement_tenancy : ""}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "default" {
  count = "${var.autoscaling_group_enabled == "true" ? 1 : 0}"

  name_prefix          = "${format("%s%s", module.label.id, var.delimiter)}"
  launch_configuration = "${var.launch_configuration_enabled == "true" ? join("", aws_launch_configuration.default.*.name) : var.launch_configuration}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]
  max_size             = "${var.max_size}"
  min_size             = "${var.min_size}"
  desired_capacity     = "${var.desired_capacity}"

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

  tags = ["${module.label.tags_as_list_of_maps}"]

  lifecycle {
    create_before_destroy = true
  }
}
