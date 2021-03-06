variable "app_cookie_name" {
  description = "The application cookie whose lifetime the ELB's cookie should follow. Only used if stickiness is set to application."
  type        = string
  default     = ""
}

variable "app_cookie_stickiness_policy_name" {
  description = "Name for App Cookie Stickiness policy. Only alphanumeric characters and hyphens allowed. Only used if stickiness is set to application."
  type        = string
  default     = ""
}

variable "app_cookie_stickiness_port" {
  description = "The load balancer port to which the policy should be applied. This must be an active listener on the load balancer. Only used if stickiness is set to application."
  type        = string
  default     = ""
}

variable "asg_target" {
  description = "Name of ASG to associate with the ELB. Leave blank if you are using this in combination with the EC2_ASG module, passing the output of this module to the EC2_ASG module. Leave blank if attached instances are not in an ASG."
  type        = string
  default     = ""
}

variable "connection_draining" {
  description = "Boolean to enable connection draining. i.e. true | false"
  type        = bool
  default     = false
}

variable "connection_draining_timeout" {
  description = "Set the timeout value for elastic loadbalancer draining policy if desired."
  type        = number
  default     = 300
}

variable "cookie_expiration_period" {
  description = "The time period after which the session cookie should be considered stale, expressed in seconds. Only used for `load_balancer` stickiness."
  type        = string
  default     = ""
}

variable "create_internal_record" {
  description = "Create Route53 Internal Record. i.e. true | false"
  type        = bool
  default     = false
}

variable "create_logging_bucket" {
  description = "Create a new S3 logging bucket. i.e. true | false"
  type        = bool
  default     = true
}

variable "cross_zone" {
  description = "Whether cross-zone load balancing is enabled for the load balancer. i.e. true | false"
  type        = bool
  default     = true
}

variable "environment" {
  description = "Application environment for which this network is being created from"
  type        = string
  default     = "Development"
}

variable "health_check_interval" {
  description = "Seconds between health checks."
  type        = number
  default     = 30
}

variable "health_check_target" {
  description = "Protocol & port check on instance. Valid pattern is <PROTOCOL>:<PORT><PATH>, where PROTOCOL values areTCP:5000 | SSL:5000 || HTTP(S) = HTTP:80/path/to/my/file."
  type        = string
  default     = "HTTP:80/"
}

variable "health_check_threshold" {
  description = "Consecutive successful checks before marking instance healthy."
  type        = number
  default     = 3
}

variable "health_check_timeout" {
  description = "Number of seconds during which no response means a failed health probe."
  type        = number
  default     = 5
}

variable "health_check_unhealthy_threshold" {
  description = "Consecutive failed checks before marking instance unhealthy."
  type        = number
  default     = 3
}

variable "idle_timeout" {
  description = "The time (in seconds) that a connection to the load balancer can remain idle, which means no data is sent over the connection. After the specified time, the load balancer closes the connection. Value from 1 - 4000"
  type        = number
  default     = 60
}

variable "instances" {
  description = "A list of EC2 instance IDs for the load balancer. Use when not assigned to auto scale group. i.e. ['i-0806906515f952316', 'i-0806906515f952316', 'i-0806906515f952316']"
  type        = list(string)
  default     = []
}

variable "instances_count" {
  description = "Total number of individual instances to attach to this CLB. Must match actual count of the `instances` parameter."
  type        = number
  default     = 0
}

variable "internal_loadbalancer" {
  description = "If true, CLB will be an internal CLB."
  type        = bool
  default     = false
}

variable "internal_record_name" {
  description = "Record Name for the new Resource Record in the Internal Hosted Zone"
  type        = string
  default     = ""
}

variable "internal_zone_id" {
  description = "The Route53 Internal Hosted Zone ID"
  type        = string
  default     = ""
}

variable "internal_zone_name" {
  description = "TLD for Internal Hosted Zone"
  type        = string
  default     = ""
}

variable "lb_cookie_stickiness_policy_name" {
  description = "Name for LB Cookie Stickiness policy. Only alphanumeric characters and hyphens allowed. Only used if stickiness is set to load_balancer."
  type        = string
  default     = ""
}

variable "lb_cookie_stickiness_port" {
  description = "The load balancer port to which the policy should be applied. This must be an active listener on the load balancer. Only used if stickiness is set to load_balancer."
  type        = string
  default     = ""
}

variable "listeners" {
  description = "List of Maps describing the LB options including instance_port (The port on the instance to route to), instance_protocol (The protocol to use to the instance: HTTP, HTTPS, TCP, SSL), lb_port (The port to listen on for the load balancer), lb_protocol (The protocol to listen on. Valid values are HTTP, HTTPS, TCP, or SSL), ssl_certificate_id (The ARN of an SSL certificate you have uploaded to AWS IAM. Only valid when lb_protocol is either HTTPS or SSL)"
  type        = list(map(string))
  default     = []
}

variable "logging_bucket_access_control" {
  description = "Define ACL for Bucket from one of the [canned ACL](https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl): private, public-read, public-read-write, aws-exec-read, authenticated-read, bucket-owner-read, bucket-owner-full-control, log-delivery-write"
  type        = string
  default     = "private"
}

variable "logging_bucket_encryption" {
  description = "Enable default bucket encryption. i.e. disabled | AES256 | aws:kms"
  type        = string
  default     = "AES256"
}

variable "logging_bucket_kms_key_id" {
  description = "The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms."
  type        = string
  default     = ""
}

variable "logging_bucket_force_destroy" {
  description = "Whether all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. ie. true"
  type        = bool
  default     = false
}

variable "logging_bucket_log_interval" {
  description = "The publishing interval in minutes."
  type        = number
  default     = 60
}

variable "logging_bucket_name" {
  description = "The number of days to retain load balancer logs. Parameter is ignored if not creating a new S3 bucket."
  type        = string
  default     = ""
}

variable "logging_bucket_prefix" {
  description = "The prefix for the location in the S3 bucket. If you don't specify a prefix, the access logs are stored in the root of the bucket."
  type        = string
  default     = "FrontendCLBLogs"
}

variable "logging_bucket_retention" {
  description = "The number of days to retain load balancer logs. Parameter is ignored if not creating a new S3 bucket."
  type        = number
  default     = 14
}

variable "name" {
  description = "This name must be unique within your set of load balancers for the region."
  type        = string
}

variable "notification_topic" {
  description = "List of SNS Topic ARNs to use for customer notifications."
  type        = list(string)
  default     = []
}

variable "rackspace_alarms_enabled" {
  description = "Specifies whether alarms will create a Rackspace ticket.  Ignored if rackspace_managed is set to false."
  type        = bool
  default     = false
}

variable "rackspace_managed" {
  description = "Boolean parameter controlling if instance will be fully managed by Rackspace support teams, created CloudWatch alarms that generate tickets, and utilize Rackspace managed SSM documents."
  type        = bool
  default     = true
}

variable "security_groups" {
  description = "A list of EC2 security groups to assign to this resource."
  type        = list(string)
}

variable "stickiness_type" {
  description = "Disable stickiness by using `none` or use `load_balancer` for enabling Enable load balancer generated cookie stickiness or use `application` for enabling application generated cookie stickiness. i.e. none | load_balancer | application"
  type        = string
  default     = "none"
}

variable "subnets" {
  description = "A list of subnet IDs to attach to the ELB."
  type        = list(string)
}

variable "tags" {
  description = "Map of tags you would like to add to the instance. i.e. {Key='Value'}"
  type        = map(string)
  default     = {}
}

