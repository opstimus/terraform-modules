locals {
  name_prefix = "${var.project}-${var.environment}-egress-probe"
}

data "aws_subnet" "probe" {
  count = length(var.subnet_ids)
  id    = var.subnet_ids[count.index]
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "/tmp/${local.name_prefix}.zip"
}

resource "aws_security_group" "probe" {
  name        = local.name_prefix
  description = local.name_prefix
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name = local.name_prefix
    },
    var.tags
  )
}

resource "aws_vpc_security_group_egress_rule" "probe_https" {
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.probe.id

  tags = merge(
    {
      Name = "${local.name_prefix}-https"
    },
    var.tags
  )
}

resource "aws_iam_role" "probe" {
  name = local.name_prefix
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
      },
    ]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "vpc_access" {
  role       = aws_iam_role.probe.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_cloudwatch_log_group" "probe" {
  count             = length(var.subnet_ids)
  name              = "/aws/lambda/${local.name_prefix}-${data.aws_subnet.probe[count.index].availability_zone}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

# One function per subnet: a function attached to several subnets would only
# test whichever one Lambda happens to pick
resource "aws_lambda_function" "probe" {
  count            = length(var.subnet_ids)
  function_name    = "${local.name_prefix}-${data.aws_subnet.probe[count.index].availability_zone}"
  role             = aws_iam_role.probe.arn
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.13"
  timeout          = 20
  memory_size      = 128
  tags             = var.tags

  vpc_config {
    subnet_ids         = [var.subnet_ids[count.index]]
    security_group_ids = [aws_security_group.probe.id]
  }

  environment {
    variables = {
      PROBE_URL = var.probe_url
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.probe,
    aws_iam_role_policy_attachment.vpc_access,
  ]
}

resource "aws_cloudwatch_event_rule" "probe" {
  name                = local.name_prefix
  description         = "Run the egress probes"
  schedule_expression = var.schedule_expression
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "probe" {
  count = length(var.subnet_ids)
  rule  = aws_cloudwatch_event_rule.probe.name
  arn   = aws_lambda_function.probe[count.index].arn
}

resource "aws_lambda_permission" "probe" {
  count         = length(var.subnet_ids)
  statement_id  = "AllowEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.probe[count.index].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.probe.arn
}

# Lambda publishes Errors itself, so the alarm still gets data when egress is down
resource "aws_cloudwatch_metric_alarm" "egress" {
  count               = length(var.subnet_ids)
  alarm_name          = "${var.project}-${var.environment}: Egress check failing in ${data.aws_subnet.probe[count.index].availability_zone}"
  alarm_description   = "Private subnet ${var.subnet_ids[count.index]} cannot reach ${var.probe_url}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 2
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Maximum"
  threshold           = 1
  treat_missing_data  = "missing"
  alarm_actions       = [var.alarm_sns_arn]
  ok_actions          = [var.alarm_sns_arn]
  dimensions = {
    FunctionName = aws_lambda_function.probe[count.index].function_name
  }
  tags = var.tags
}
