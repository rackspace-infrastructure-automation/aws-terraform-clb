# aws-terraform-clb

This module creates a Classic Load Balancer also called ELB. Not to be confused with NLB or ALB which are preferred.

## Basic Usage

```
module "clb" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-clb//?ref=v0.12.0"

  name            = "<name>"
  instances       = ["i-01", "i-02"]
  instances_count = 2
  security_groups = ["sg-01", "sg-02"]
  subnets         = ["subnet-01", "subnet-02"]

  tags = {
    Right = "Said"
  }

  listeners = [
    {
      instance_port     = 8000
      instance_protocol = "HTTP"
      lb_port           = 80
      lb_protocol       = "HTTP"
    },
  ]
}
```

Full working references are available at [examples](examples)
## Other TF Modules Used  
Using [aws-terraform-cloudwatch\_alarm](https://github.com/rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm) to create the following CloudWatch Alarms:
 - unhealthy\_host\_count\_alarm

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.1.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| app\_cookie\_name | The application cookie whose lifetime the ELB's cookie should follow. Only used if stickiness is set to application. | `string` | `""` | no |
| app\_cookie\_stickiness\_policy\_name | Name for App Cookie Stickiness policy. Only alphanumeric characters and hyphens allowed. Only used if stickiness is set to application. | `string` | `""` | no |
| app\_cookie\_stickiness\_port | The load balancer port to which the policy should be applied. This must be an active listener on the load balancer. Only used if stickiness is set to application. | `string` | `""` | no |
| asg\_target | Name of ASG to associate with the ELB. Leave blank if you are using this in combination with the EC2\_ASG module, passing the output of this module to the EC2\_ASG module. Leave blank if attached instances are not in an ASG. | `string` | `""` | no |
| connection\_draining | Boolean to enable connection draining. i.e. true \| false | `bool` | `false` | no |
| connection\_draining\_timeout | Set the timeout value for elastic loadbalancer draining policy if desired. | `number` | `300` | no |
| cookie\_expiration\_period | The time period after which the session cookie should be considered stale, expressed in seconds. Only used for `load_balancer` stickiness. | `string` | `""` | no |
| create\_internal\_record | Create Route53 Internal Record. i.e. true \| false | `bool` | `false` | no |
| create\_logging\_bucket | Create a new S3 logging bucket. i.e. true \| false | `bool` | `true` | no |
| cross\_zone | Whether cross-zone load balancing is enabled for the load balancer. i.e. true \| false | `bool` | `true` | no |
| environment | Application environment for which this network is being created from one of the following: 'Development', 'Integration', 'PreProduction', 'Production', 'QA', 'Staging', 'Test' | `string` | `"Development"` | no |
| health\_check\_interval | Seconds between health checks. | `number` | `30` | no |
| health\_check\_target | Protocol & port check on instance. Valid pattern is <PROTOCOL>:<PORT><PATH>, where PROTOCOL values areTCP:5000 \| SSL:5000 \|\| HTTP(S) = HTTP:80/path/to/my/file. | `string` | `"HTTP:80/"` | no |
| health\_check\_threshold | Consecutive successful checks before marking instance healthy. | `number` | `3` | no |
| health\_check\_timeout | Number of seconds during which no response means a failed health probe. | `number` | `5` | no |
| health\_check\_unhealthy\_threshold | Consecutive failed checks before marking instance unhealthy. | `number` | `3` | no |
| idle\_timeout | The time (in seconds) that a connection to the load balancer can remain idle, which means no data is sent over the connection. After the specified time, the load balancer closes the connection. Value from 1 - 4000 | `number` | `60` | no |
| instances | A list of EC2 instance IDs for the load balancer. Use when not assigned to auto scale group. i.e. ['i-0806906515f952316', 'i-0806906515f952316', 'i-0806906515f952316'] | `list(string)` | `[]` | no |
| instances\_count | Total number of individual instances to attach to this CLB. Must match actual count of the `instances` parameter. | `string` | `""` | no |
| internal\_loadbalancer | If true, CLB will be an internal CLB. | `bool` | `false` | no |
| internal\_record\_name | Record Name for the new Resource Record in the Internal Hosted Zone | `string` | `""` | no |
| internal\_zone\_id | The Route53 Internal Hosted Zone ID | `string` | `""` | no |
| internal\_zone\_name | TLD for Internal Hosted Zone | `string` | `""` | no |
| lb\_cookie\_stickiness\_policy\_name | Name for LB Cookie Stickiness policy. Only alphanumeric characters and hyphens allowed. Only used if stickiness is set to load\_balancer. | `string` | `""` | no |
| lb\_cookie\_stickiness\_port | The load balancer port to which the policy should be applied. This must be an active listener on the load balancer. Only used if stickiness is set to load\_balancer. | `string` | `""` | no |
| listeners | List of Maps describing the LB options including instance\_port (The port on the instance to route to), instance\_protocol (The protocol to use to the instance: HTTP, HTTPS, TCP, SSL), lb\_port (The port to listen on for the load balancer), lb\_protocol (The protocol to listen on. Valid values are HTTP, HTTPS, TCP, or SSL), ssl\_certificate\_id (The ARN of an SSL certificate you have uploaded to AWS IAM. Only valid when lb\_protocol is either HTTPS or SSL) | `list(map(string))` | `[]` | no |
| logging\_bucket\_access\_control | Define ACL for Bucket from one of the [canned ACL](https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl): private, public-read, public-read-write, aws-exec-read, authenticated-read, bucket-owner-read, bucket-owner-full-control, log-delivery-write | `string` | `"bucket-owner-full-control"` | no |
| logging\_bucket\_encryption | Enable default bucket encryption. i.e. disabled \| AES256 \| aws:kms | `string` | `"AES256"` | no |
| logging\_bucket\_force\_destroy | Whether all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. ie. true | `bool` | `false` | no |
| logging\_bucket\_kms\_key\_id | The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse\_algorithm as aws:kms. | `string` | `""` | no |
| logging\_bucket\_log\_interval | The publishing interval in minutes. | `number` | `60` | no |
| logging\_bucket\_name | The number of days to retain load balancer logs. Parameter is ignored if not creating a new S3 bucket. | `string` | `""` | no |
| logging\_bucket\_prefix | The prefix for the location in the S3 bucket. If you don't specify a prefix, the access logs are stored in the root of the bucket. | `string` | `"FrontendCLBLogs"` | no |
| logging\_bucket\_retention | The number of days to retain load balancer logs. Parameter is ignored if not creating a new S3 bucket. | `number` | `14` | no |
| name | This name must be unique within your set of load balancers for the region. | `string` | n/a | yes |
| notification\_topic | List of SNS Topic ARNs to use for customer notifications. | `list(string)` | `[]` | no |
| rackspace\_alarms\_enabled | Specifies whether alarms will create a Rackspace ticket.  Ignored if rackspace\_managed is set to false. | `bool` | `false` | no |
| rackspace\_managed | Boolean parameter controlling if instance will be fully managed by Rackspace support teams, created CloudWatch alarms that generate tickets, and utilize Rackspace managed SSM documents. | `bool` | `true` | no |
| security\_groups | A list of EC2 security groups to assign to this resource. | `list(string)` | n/a | yes |
| stickiness\_type | Disable stickiness by using `none` or use `load_balancer` for enabling Enable load balancer generated cookie stickiness or use `application` for enabling application generated cookie stickiness. i.e. none \| load\_balancer \| application | `string` | `"none"` | no |
| subnets | A list of subnet IDs to attach to the ELB. | `list(string)` | n/a | yes |
| tags | Map of tags you would like to add to the instance. i.e. {Key='Value'} | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| clb\_arn | ARN of the ELB. |
| clb\_dns\_name | The DNS name of the ELB. |
| clb\_instances | The list of instances in the ELB. |
| clb\_source\_security\_group | The name of the security group that you can use as part of your inbound rules for your load balancer's back-end application instances. Use this for Classic or Default VPC only. |
| clb\_source\_security\_group\_id | The ID of the security group that you can use as part of your inbound rules for your load balancer's back-end application instances. Only available on ELBs launched in a VPC. |
| clb\_zone\_id | The canonical hosted zone ID of the ELB (to be used in a Route 53 Alias record) |
| name | The name of the ELB. |

