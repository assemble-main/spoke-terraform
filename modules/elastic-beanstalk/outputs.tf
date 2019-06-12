output "eb_elb_security_group_id" {
  description = "Group ID of the EB ELB security group."
  value       = "${aws_security_group.spoke_eb_elb.id}"
}

output "eb_ec2_security_group_id" {
  description = "Group ID of the EB EC2 security group."
  value       = "${aws_security_group.spoke_eb_ec2.id}"
}

output "eb_env_cname" {
  description = "Fully qualified DNS name for the Environment."
  value       = "${aws_elastic_beanstalk_environment.spoke_admin.cname}"
}
