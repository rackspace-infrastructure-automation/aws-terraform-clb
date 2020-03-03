/**
 * # aws-terraform-clb
 *
 * This module creates a Classic Load Balancer also called ELB. Not to be confused with NLB or ALB which are preferred.
 *
 * ## Basic Usage
 *
 * ```
 * module "clb" {
 *   source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-clb//?ref=v0.12.0"
 *
 *   name            = "<name>"
 *   instances       = ["i-01", "i-02"]
 *   instances_count = 2
 *   security_groups = ["sg-01", "sg-02"]
 *   subnets         = ["subnet-01", "subnet-02"]
 *
 *   tags = {
 *     Right = "Said"
 *   }
 *
 *   listeners = [
 *     {
 *       instance_port     = 8000
 *       instance_protocol = "HTTP"
 *       lb_port           = 80
 *       lb_protocol       = "HTTP"
 *     },
 *   ]
 * }
 * ```
 *
 * Full working references are available at [examples](examples)
 * ## Other TF Modules Used
 * Using [aws-terraform-cloudwatch_alarm](https://github.com/rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm) to create the following CloudWatch Alarms:
 *  - unhealthy_host_count_alarm
 */

data "aws_region" "current_region" {
}

data "aws_caller_identity" "current_identity" {
}

data "aws_elb_service_account" "main" {
}

locals {
  acl_list = ["authenticated-read", "aws-exec-read", "bucket-owner-read", "bucket-owner-full-control", "log-delivery-write", "private", "public-read", "public-read-write"]
  env_list = ["Development", "Integration", "PreProduction", "Production", "QA", "Staging", "Test"]

  bucket_acl  = contains(local.acl_list, var.logging_bucket_access_control) ? var.logging_bucket_access_control : "bucket-owner-full-control"
  environment = contains(local.env_list, var.environment) ? var.environment : "Development"

  default_tags = {
    Environment     = var.environment
    ServiceProvider = "Rackspace"
  }

  merged_tags = merge(local.default_tags, var.tags)

  access_logs_config = var.logging_bucket_name != "" ? "enabled" : "disabled"

  access_logs = {
    enabled = [
      {
        bucket        = var.logging_bucket_name
        bucket_prefix = var.logging_bucket_prefix
        interval      = var.logging_bucket_log_interval
        enabled       = true
      },
    ]
    disabled = []
  }
}

resource "aws_elb" "clb" {
  name = var.name

  internal = var.internal_loadbalancer
  dynamic "access_logs" {
    for_each = local.access_logs[local.access_logs_config]
    content {
      bucket        = access_logs.value.bucket
      bucket_prefix = lookup(access_logs.value, "bucket_prefix", null)
      enabled       = lookup(access_logs.value, "enabled", null)
      interval      = lookup(access_logs.value, "interval", null)
    }
  }

  dynamic "listener" {
    for_each = var.listeners
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      instance_port      = listener.value.instance_port
      instance_protocol  = listener.value.instance_protocol
      lb_port            = listener.value.lb_port
      lb_protocol        = listener.value.lb_protocol
      ssl_certificate_id = lookup(listener.value, "ssl_certificate_id", null)
    }
  }

  health_check {
    healthy_threshold   = var.health_check_threshold
    interval            = var.health_check_interval
    target              = var.health_check_target
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  connection_draining         = var.connection_draining
  connection_draining_timeout = var.connection_draining_timeout
  cross_zone_load_balancing   = var.cross_zone
  idle_timeout                = var.idle_timeout
  security_groups             = var.security_groups
  subnets                     = var.subnets

  tags = local.merged_tags

  depends_on = [aws_s3_bucket_policy.log_bucket_policy]
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  count = var.asg_target != "" ? 1 : 0

  autoscaling_group_name = var.asg_target
  elb                    = aws_elb.clb.id
}

resource "aws_elb_attachment" "instance" {
  count = var.instances_count

  elb      = aws_elb.clb.id
  instance = var.instances[count.index]
}

resource "aws_lb_cookie_stickiness_policy" "clb_lb_policy" {
  count = var.stickiness_type == "load_balancer" ? 1 : 0

  cookie_expiration_period = var.cookie_expiration_period
  lb_port                  = var.lb_cookie_stickiness_port
  load_balancer            = aws_elb.clb.id
  name                     = var.lb_cookie_stickiness_policy_name
}

resource "aws_app_cookie_stickiness_policy" "clb_app_policy" {
  count = var.stickiness_type == "application" ? 1 : 0

  cookie_name   = var.app_cookie_name
  lb_port       = var.app_cookie_stickiness_port
  load_balancer = aws_elb.clb.name
  name          = var.app_cookie_stickiness_policy_name
}

# create s3 bucket if needed
resource "aws_s3_bucket" "log_bucket" {
  count = var.create_logging_bucket ? 1 : 0

  acl    = local.bucket_acl
  bucket = var.logging_bucket_name

  force_destroy = var.logging_bucket_force_destroy

  tags = local.merged_tags

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.logging_bucket_encryption_kms_mster_key
        sse_algorithm     = var.logging_bucket_encryption
      }
    }
  }

  lifecycle_rule {
    enabled = true
    prefix  = var.logging_bucket_prefix

    expiration {
      days = var.logging_bucket_retention
    }
  }
}

# s3 policy needs to be separate since you can't reference the bucket for the reference.
resource "aws_s3_bucket_policy" "log_bucket_policy" {
  count = var.create_logging_bucket ? 1 : 0

  bucket = aws_s3_bucket.log_bucket[0].id

  policy = <<POLICY
{
  "Id": "Policy1529427095432",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.log_bucket[0].arn}/*",
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
module "unhealthy_host_count_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.1"

  alarm_description        = "Unhealthy Host count is greater than or equal to threshold, creating ticket."
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  evaluation_periods       = 10
  metric_name              = "UnHealthyHostCount"
  name                     = "${var.name}_unhealthy_host_count_alarm"
  namespace                = "AWS/ELB"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.rackspace_alarms_enabled
  rackspace_managed        = var.rackspace_managed
  severity                 = "emergency"
  statistic                = "Maximum"
  threshold                = 1
  unit                     = "Count"

  dimensions = [
    {
      LoadBalancerName = aws_elb.clb.id
    },
  ]
}

# create r53 record with alias
resource "aws_route53_record" "zone_record_alias" {
  count = var.create_internal_record ? 1 : 0

  name    = var.internal_record_name
  type    = "A"
  zone_id = var.internal_zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_elb.clb.dns_name
    zone_id                = aws_elb.clb.zone_id
  }
}

