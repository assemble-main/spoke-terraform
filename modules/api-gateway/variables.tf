variable "client_name_friendly" {
  type        = "string"
  description = "Human-readable client name to use in resource Name tags."
}

variable "aws_client_tag" {
  type        = "string"
  description = "The value for AWS cost allocation tag `user:client`."
}

variable "aws_stack_tag" {
  type        = "string"
  description = "The value for AWS cost allocation tag `user:stack`."
  default     = "production"
}

variable "invoke_arn" {
  type        = "string"
  description = "The gateway's target Lambda function invoke ARN. Example: aws_lambda_function.spoke.invoke_arn"
}

variable "function_arn" {
  type        = "string"
  description = "The gateway's target Lambda function ARN. Example: aws_lambda_function.spoke.arn"
}
