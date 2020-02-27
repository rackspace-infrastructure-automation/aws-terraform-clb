provider "aws" {
  region = "us-west-2"
}

module "clb" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-clb//?ref=v0.0.8"

  # Required
  clb_name        = "<name>"
  security_groups = ["sg-01", "sg-02"]
  instances       = ["i-01", "i-02"]
  instances_count = 2
  subnets         = ["subnet-01", "subnet-02"]

  # Optional
  tags = [
    {
      "Right" = "Said"
    },
  ]

  internal_loadbalancer = false

  # Logging Buckets
  create_logging_bucket     = false
  logging_bucket_name       = "<existing_bucket_name>"
  logging_bucket_encryption = "AES256"

  # Rackspace Managed
  rackspace_managed = true

  asg_target = "asg_name"

  # One of 'none'|'load_balancer'|'application' and the appropriate block below
  stickiness_type = "none"

  # Application Stickiness
  app_cookie_name                   = "test_cookie"
  app_cookie_stickiness_port        = 80
  app_cookie_stickiness_policy_name = "test-cookie-policy"

  # Load Balancer Stickiness
  lb_cookie_stickiness_port       = 80
  lb_cookie_stickines_policy_name = "test-cookie-policy"
  cookie_expiration_period        = 600

  listeners = [
    {
      instance_port     = 8000
      instance_protocol = "HTTP"
      lb_port           = 80
      lb_protocol       = "HTTP"
    },
  ]

  connection_draining         = true
  connection_draining_timeout = 30
}

