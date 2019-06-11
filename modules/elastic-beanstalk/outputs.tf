output "eb_elb_security_group_id" {
  description = "Group ID of the EB ELB security group."
  value       = "${aws_security_group.spoke_eb_elb.id}"
}

output "eb_ec2_security_group_id" {
  description = "Group ID of the EB EC2 security group."
  value       = "${aws_security_group.spoke_eb_ec2.id}"
}
