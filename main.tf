data "aws_region" "current_region" {}

data "aws_caller_identity" "current_identity" {}

data "aws_elb_service_account" "main" {}

locals {
  env_list = ["Development", "Integration", "PreProduction", "Production", "QA", "Staging", "Test"]
  acl_list = ["authenticated-read", "aws-exec-read", "bucket-owner-read", "bucket-owner-full-control", "log-delivery-write", "private", "public-read", "public-read-write"]

  bucket_acl  = "${contains(local.acl_list, var.logging_bucket_access_control) ? var.logging_bucket_access_control:"bucket-owner-full-control"}"
  environment = "${contains(local.env_list, var.environment) ? var.environment:"Development"}"

  default_tags = {
    Environment     = "${var.environment}"
    ServiceProvider = "Rackspace"
  }

  merged_tags = "${merge(local.default_tags, var.tags)}"

  sns_topic = "arn:aws:sns:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_identity.account_id}:rackspace-support-emergency"

  alarm_action_config = "${var.rackspace_managed ? "managed":"unmanaged"}"

  alarm_actions = {
    managed = ["${local.sns_topic}"]

    unmanaged = ["${var.custom_alarm_sns_topic}"]
  }

  ok_action_config = "${var.rackspace_managed ? "managed":"unmanaged"}"

  ok_actions = {
    managed = ["${local.sns_topic}"]

    unmanaged = ["${var.custom_ok_sns_topic}"]
  }

  alarm_setting = "${local.alarm_actions[local.alarm_action_config]}"
  ok_setting    = "${local.ok_actions[local.ok_action_config]}"

  access_logs_config = "${var.logging_bucket_name != "" ? "enabled":"disabled"}"

  access_logs = {
    enabled = [{
      bucket        = "${var.logging_bucket_name}"
      bucket_prefix = "${var.logging_bucket_prefix}"
      interval      = "${var.logging_bucket_log_interval}"
      enabled       = true
    }]

    disabled = "${list()}"
  }
}

resource "aws_elb" "clb" {
  depends_on = ["aws_s3_bucket.log_bucket"]
  name       = "${var.clb_name}"

  access_logs = ["${local.access_logs[local.access_logs_config]}"]

  listener = "${var.listeners}"

  health_check {
    healthy_threshold   = "${var.health_check_threshold}"
    unhealthy_threshold = "${var.health_check_unhealthy_threshold}"
    timeout             = "${var.health_check_timeout}"
    target              = "${var.health_check_target}"
    interval            = "${var.health_check_interval}"
  }

  subnets                     = ["${var.subnets}"]
  instances                   = ["${var.instances}"]
  cross_zone_load_balancing   = "${var.cross_zone}"
  idle_timeout                = "${var.idle_timeout}"
  connection_draining         = "${var.connection_draining}"
  connection_draining_timeout = "${var.connection_draining_timeout}"

  tags = "${local.merged_tags}"
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  count                  = "${var.asg_target != "" ? 1:0}"
  autoscaling_group_name = "${var.asg_target}"
  elb                    = "${aws_elb.clb.id}"
}

resource "aws_lb_cookie_stickiness_policy" "clb_lb_policy" {
  count                    = "${var.stickiness_type == "load_balancer" ? 1:0}"
  name                     = "${var.lb_cookie_stickines_policy_name}"
  load_balancer            = "${aws_elb.clb.id}"
  lb_port                  = "${var.lb_cookie_stickiness_port}"
  cookie_expiration_period = "${var.cookie_expiration_period}"
}

resource "aws_app_cookie_stickiness_policy" "clb_app_policy" {
  count         = "${var.stickiness_type == "application" ? 1:0}"
  name          = "${var.app_cookie_stickiness_policy_name}"
  load_balancer = "${aws_elb.clb.name}"
  lb_port       = "${var.app_cookie_stickiness_port}"
  cookie_name   = "${var.app_cookie_name}"
}

# create s3 bucket if needed
resource "aws_s3_bucket" "log_bucket" {
  count  = "${var.create_logging_bucket ? 1:0}"
  bucket = "${var.logging_bucket_name}"
  acl    = "${local.bucket_acl}"

  force_destroy = "${var.logging_bucket_force_destroy}"

  tags = "${local.merged_tags}"

  server_side_encryption_configuration {
    "rule" {
      "apply_server_side_encryption_by_default" {
        kms_master_key_id = "${var.logging_bucket_encryption_kms_mster_key}"
        sse_algorithm     = "${var.logging_bucket_encryption}"
      }
    }
  }

  lifecycle_rule {
    enabled = true
    prefix  = "${var.logging_bucket_prefix}"

    expiration {
      days = "${var.logging_bucket_retention}"
    }
  }
}

# s3 policy needs to be separate since you can't reference the bucket for the reference.
resource "aws_s3_bucket_policy" "log_bucket_policy" {
  count  = "${var.create_logging_bucket ? 1:0}"
  bucket = "${aws_s3_bucket.log_bucket.id}"

  policy = <<POLICY
{
  "Id": "Policy1529427095432",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1529427092463",
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.log_bucket.arn}/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.main.arn}"
        ]
      }
    }
  ]
}
POLICY
}

# enable cloudwatch/RS ticket creation
resource "aws_cloudwatch_metric_alarm" "unhealthy_host_count_alarm" {
  count = "${var.rackspace_managed ? 1:0}"

  alarm_name          = "${format("%v_unhealthy_host_count_alarm", var.clb_name)}"
  alarm_description   = "Unhealthy Host count is greater than or equal to threshold, creating ticket."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 10
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1
  unit                = "Count"

  dimensions {
    LoadBalancer = "${aws_elb.clb.id}"
  }

  alarm_actions = ["${local.alarm_setting}"]

  ok_actions = ["${local.ok_actions[local.ok_action_config]}"]
}

# create r53 record with alias
resource "aws_route53_record" "zone_record_alias" {
  count   = "${var.create_internal_record ? 1:0}"
  name    = "${var.internal_zone_name}"
  type    = "A"
  zone_id = "${var.internal_zone_id}"

  alias {
    evaluate_target_health = true
    name                   = "${var.internal_zone_name}"
    zone_id                = "${var.internal_zone_id}"
  }
}
