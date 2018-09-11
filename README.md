
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| app_cookie_name | The application cookie whose lifetime the ELB's cookie should follow. Only used if stickiness is set to application. | string | `` | no |
| app_cookie_stickiness_policy_name | Name for App Cookie Stickiness policy. Only alphanumeric characters and hyphens allowed. Only used if stickiness is set to application. | string | `` | no |
| app_cookie_stickiness_port | The load balancer port to which the policy should be applied. This must be an active listener on the load balancer. Only used if stickiness is set to application. | string | `` | no |
| asg_target | Name of ASG to associate with the ELB. Leave blank if attatched instances are not in an ASG. | string | `` | no |
| clb_name | This name must be unique within your set of load balancers for the region. | string | - | yes |
| connection_draining | Boolean to enable connection draining. i.e. true | false | string | `false` | no |
| connection_draining_timeout | Set the timeout value for elastic loadbalancer draining policy if desired. | string | `0` | no |
| cookie_expiration_period | The time period after which the session cookie should be considered stale, expressed in seconds. Only used for `load_balancer` stickiness. | string | `` | no |
| create_internal_record | Create Route53 Internal Record. i.e. true | false | string | `false` | no |
| create_logging_bucket | Create a new S3 logging bucket. i.e. true | false | string | `true` | no |
| cross_zone | Whether cross-zone load balancing is enabled for the load balancer. i.e. true | false | string | `true` | no |
| custom_alarm_sns_topic | If not Rackspace managed, you can use a custom SNS topic to send alerts to. | string | `` | no |
| custom_ok_sns_topic | If not Rackspace managed, you can use a custom SNS topic to send alerts to. | string | `` | no |
| environment | Application environment for which this network is being created from one of the following: 'Development', 'Integration', 'PreProduction', 'Production', 'QA', 'Staging', 'Test' | string | `Development` | no |
| health_check_interval | Seconds between health checks. | string | `30` | no |
| health_check_target | Protocol & port check on instance. Valid pattern is <PROTOCOL>:<PORT><PATH>, where PROTOCOL values areTCP:5000 | SSL:5000 || HTTP(S) = HTTP:80/path/to/my/file. | string | `HTTP:80/` | no |
| health_check_threshold | Consecutive successful checks before marking instance healthy. | string | `3` | no |
| health_check_timeout | Number of seconds during which no response means a failed health probe. | string | `5` | no |
| health_check_unhealthy_threshold | Consecutive failed checks before marking instance unhealthy. | string | `3` | no |
| idle_timeout | The time (in seconds) that a connection to the load balancer can remain idle, which means no data is sent over the connection. After the specified time, the load balancer closes the connection. Value from 1 - 4000 | string | `60` | no |
| instances | A list of EC2 instance IDs for the load balancer. Use when not assigned to auto scale group. i.e. ['i-0806906515f952316', 'i-0806906515f952316', 'i-0806906515f952316'] | list | - | yes |
| internal_loadbalancer | If true, CLB will be an internal CLB. | string | `false` | no |
| internal_record_name | Record Name for the new Resource Record in the Internal Hosted Zone | string | `` | no |
| internal_zone_id | The Route53 Internal Hosted Zone ID | string | `` | no |
| internal_zone_name | TLD for Internal Hosted Zone | string | `` | no |
| lb_cookie_stickines_policy_name | Name for LB Cookie Stickiness policy. Only alphanumeric characters and hyphens allowed. Only used if stickiness is set to load_balancer. | string | `` | no |
| lb_cookie_stickiness_port | The load balancer port to which the policy should be applied. This must be an active listener on the load balancer. Only used if stickiness is set to load_balancer. | string | `` | no |
| listeners | List of Maps describing the LB options including instance_port (The port on the instance to route to), instance_protocol (The protocol to use to the instance: HTTP, HTTPS, TCP, SSL), lb_port (The port to listen on for the load balancer), lb_protocol (The protocol to listen on. Valid values are HTTP, HTTPS, TCP, or SSL), ssl_certificate_id (The ARN of an SSL certificate you have uploaded to AWS IAM. Only valid when lb_protocol is either HTTPS or SSL) | list | `<list>` | no |
| logging_bucket_access_control | Define ACL for Bucket from one of the [canned ACL](https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl): private, public-read, public-read-write, aws-exec-read, authenticated-read, bucket-owner-read, bucket-owner-full-control, log-delivery-write | string | `bucket-owner-full-control` | no |
| logging_bucket_encryption | Enable default bucket encryption. i.e. disabled | AES256 | aws:kms | string | `AES256` | no |
| logging_bucket_encryption_kms_mster_key | The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. | string | `` | no |
| logging_bucket_force_destroy | Whether all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. ie. true | string | `false` | no |
| logging_bucket_log_interval | The publishing interval in minutes. | string | `60` | no |
| logging_bucket_name | The number of days to retain load balancer logs. Parameter is ignored if not creating a new S3 bucket. | string | `` | no |
| logging_bucket_prefix | The prefix for the location in the S3 bucket. If you don't specify a prefix, the access logs are stored in the root of the bucket. | string | `FrontendCLBLogs` | no |
| logging_bucket_retention | The number of days to retain load balancer logs. Parameter is ignored if not creating a new S3 bucket. | string | `14` | no |
| rackspace_managed | Boolean for using Rackspace Managed Services. i.e. true | false | string | `true` | no |
| security_groups | A list of EC2 security groups to assign to this resource. | list | - | yes |
| stickiness_type | Disable stickiness by using `none` or use `load_balancer` for enabling Enable load balancer generated cookie stickiness or use `application` for enabling application generated cookie stickiness. i.e. none | load_balancer | application | string | `none` | no |
| subnets | A list of subnet IDs to attach to the ELB. | list | - | yes |
| tags | Map of tags you would like to add to the instance. i.e. {Key='Value'} | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| clb_arn | ARN of the ELB. |
| clb_dns_name | The DNS name of the ELB. |
| clb_instances | The list of instances in the ELB. |
| clb_name | The name of the ELB. |
| clb_source_security_group | The name of the security group that you can use as part of your inbound rules for your load balancer's back-end application instances. Use this for Classic or Default VPC only. |
| clb_source_security_group_id | The ID of the security group that you can use as part of your inbound rules for your load balancer's back-end application instances. Only available on ELBs launched in a VPC. |
| clb_zone_id | The canonical hosted zone ID of the ELB (to be used in a Route 53 Alias record) |

