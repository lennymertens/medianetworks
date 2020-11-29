resource "aws_iam_role" "tf_role" {
  name = "tf_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "tf_pa" {
  role = "tf_role"
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
  depends_on = [aws_iam_role.tf_role]
}

resource "aws_lambda_function" "tf_function" {
  filename = "lambda_function-1.zip"
  function_name = "tf_function"
  role = aws_iam_role.tf_role.arn
  handler = "lambda_function-1.lambda_handler"
  runtime = "python3.8"
}

resource "aws_api_gateway_rest_api" "tf_api" {
  name = "tf_api"
}

resource "aws_api_gateway_resource" "tf_resource" {
  rest_api_id = aws_api_gateway_rest_api.tf_api.id
  parent_id = aws_api_gateway_rest_api.tf_api.root_resource_id
  path_part = "tf_function"
}

resource "aws_api_gateway_method" "tf_method" {
  rest_api_id = aws_api_gateway_rest_api.tf_api.id
  resource_id = aws_api_gateway_resource.tf_resource.id
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "tf_integration" {
  rest_api_id = aws_api_gateway_rest_api.tf_api.id
  resource_id = aws_api_gateway_resource.tf_resource.id
  http_method = aws_api_gateway_method.tf_method.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.tf_function.invoke_arn
}

resource "aws_api_gateway_deployment" "tf_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.tf_api.id
  stage_name = "default"
  depends_on = [aws_api_gateway_integration.tf_integration]
}

resource "aws_lambda_permission" "tf_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tf_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.tf_api.execution_arn}/*/*"
}

resource "local_file" "index" {
  content = <<EOF
    <?php echo file_get_contents('${aws_api_gateway_deployment.tf_api_deployment.invoke_url}/${aws_lambda_function.tf_function.function_name}'); ?>
    <br>
    <img src='https://terraformbucketvanlenny.s3-eu-west-1.amazonaws.com/image.png>
    <!--image file stored on S3-->"
    EOF
    filename = "index.php"
    depends_on = [aws_api_gateway_deployment.tf_api_deployment]
}