output "invoke_arn" {
  description = "The invoke ARN of the Spoke Lambda function."
  value       = "${aws_lambda_function.spoke.invoke_arn}"
}

output "function_arn" {
  description = "The ARN of the Spoke Lambda function."
  value       = "${aws_lambda_function.spoke.arn}"
}

output "lambda_security_group_id" {
  description = "Group ID of the lambda security group."
  value       = "${aws_security_group.lambda.id}"
}
