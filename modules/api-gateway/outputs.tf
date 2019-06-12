output "gateway_url" {
  description = "The URL of the API gateway."
  value       = "${aws_api_gateway_deployment.spoke.invoke_url}"
}

output "lambda_domain" {
  description = "Qualified URL for Lambda."
  value       = "${aws_api_gateway_domain_name.spoke_lambda.regional_domain_name}"
}
