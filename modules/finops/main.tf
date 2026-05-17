data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_role" "lambda_finops" {
  name = "NexusCore_role_lambda_finops"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_finops" {
  name = "NexusCore_policy_lambda_finops"
  role = aws_iam_role.lambda_finops.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ControlASG"
        Effect = "Allow"
        Action = [
          "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:DescribeAutoScalingGroups"
        ]
        Resource = "*"
      },
      {
        Sid    = "ControlRDS"
        Effect = "Allow"
        Action = [
          "rds:StopDBInstance",
          "rds:StartDBInstance",
          "rds:DescribeDBInstances"
        ]
        Resource = "arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:db:nexuscore-mysql"
      },
      {
        Sid    = "LogsCloudWatch"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Sid      = "AlertasSNS"
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = var.sns_topic_arn
      }
    ]
  })
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "stop" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  function_name    = "nexuscore-finops-stop"
  role             = aws_iam_role.lambda_finops.arn
  handler          = "lambda_function.handler"
  runtime          = "python3.12"
  timeout          = 60

  environment {
    variables = {
      ASG_NAME = var.asg_name
      RDS_ID   = var.rds_identifier
      ACTION   = "stop"
    }
  }

  tags = { Name = "NexusCore_lambda_finops_stop" }
}

resource "aws_lambda_function" "start" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  function_name    = "nexuscore-finops-start"
  role             = aws_iam_role.lambda_finops.arn
  handler          = "lambda_function.handler"
  runtime          = "python3.12"
  timeout          = 60

  environment {
    variables = {
      ASG_NAME = var.asg_name
      RDS_ID   = var.rds_identifier
      ACTION   = "start"
    }
  }

  tags = { Name = "NexusCore_lambda_finops_start" }
}

resource "aws_cloudwatch_event_rule" "stop" {
  name                = "NexusCore-schedule-stop"
  description         = "Apagar recursos NexusCore a las 20:00 hora Chile"
  schedule_expression = "cron(0 0 * * ? *)"
}

resource "aws_cloudwatch_event_rule" "start" {
  name                = "NexusCore-schedule-start"
  description         = "Encender recursos NexusCore a las 08:00 hora Chile"
  schedule_expression = "cron(0 12 * * ? *)"
}

resource "aws_cloudwatch_event_target" "stop" {
  rule = aws_cloudwatch_event_rule.stop.name
  arn  = aws_lambda_function.stop.arn
}

resource "aws_cloudwatch_event_target" "start" {
  rule = aws_cloudwatch_event_rule.start.name
  arn  = aws_lambda_function.start.arn
}

resource "aws_lambda_permission" "stop" {
  statement_id  = "PermitirEventBridgeStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop.arn
}

resource "aws_lambda_permission" "start" {
  statement_id  = "PermitirEventBridgeStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start.arn
}