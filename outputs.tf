output "clb_arn" {
  description = "ARN of the ELB."
  value       = "${aws_elb.clb.arn}"
}

output "clb_name" {
  description = "The name of the ELB."
  value       = "${aws_elb.clb.name}"
}

output "clb_dns_name" {
  description = "The DNS name of the ELB."
  value       = "${aws_elb.clb.dns_name}"
}

output "clb_instances" {
  description = "The list of instances in the ELB."
  value       = "${aws_elb.clb.instances}"
}

output "clb_source_security_group" {
  description = "The name of the security group that you can use as part of your inbound rules for your load balancer's back-end application instances. Use this for Classic or Default VPC only."
  value       = "${aws_elb.clb.source_security_group}"
}

output "clb_source_security_group_id" {
  description = "The ID of the security group that you can use as part of your inbound rules for your load balancer's back-end application instances. Only available on ELBs launched in a VPC."
  value       = "${aws_elb.clb.source_security_group_id}"
}

output "clb_zone_id" {
  description = "The canonical hosted zone ID of the ELB (to be used in a Route 53 Alias record)"
  value       = "${aws_elb.clb.zone_id}"
}
