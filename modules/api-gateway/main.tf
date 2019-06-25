# Create API Gateway
# Source: https://www.terraform.io/docs/providers/aws/r/api_gateway_rest_api.html
resource "aws_api_gateway_rest_api" "spoke" {
  name        = "${var.aws_client_tag}-SpokeAPIGateway"
  description = "Spoke P2P Testing Platform for ${var.client_name_friendly}."
}

# Proxy path
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.spoke.id}"
  parent_id   = "${aws_api_gateway_rest_api.spoke.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.spoke.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.spoke.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${var.invoke_arn}"
}

# Root path
resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.spoke.id}"
  resource_id   = "${aws_api_gateway_rest_api.spoke.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.spoke.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${var.invoke_arn}"
}

# Gateway Deployment - activate the above configuration
resource "aws_api_gateway_deployment" "spoke" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
    "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.spoke.id}"
  stage_name  = "latest"
}

# Create named stage with tags for Spoke
# Source: https://www.terraform.io/docs/providers/aws/r/api_gateway_stage.html
resource "aws_api_gateway_stage" "spoke_latest" {
  stage_name    = "latest"
  rest_api_id   = "${aws_api_gateway_rest_api.spoke.id}"
  deployment_id = "${aws_api_gateway_deployment.spoke.id}"

  tags = "${var.cost_allocation_tags}"
}

# Allow API Gateway to access Lambda
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${var.function_arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.spoke.execution_arn}/*/*"
}

resource "aws_api_gateway_domain_name" "spoke_lambda" {
  domain_name              = "lambda.${var.base_domain}"
  regional_certificate_arn = "${var.certificate_arn}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "spoke_lambda" {
  # base_path is ommitted to use root
  api_id      = "${aws_api_gateway_rest_api.spoke.id}"
  stage_name  = "${aws_api_gateway_deployment.spoke.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.spoke_lambda.domain_name}"
}
