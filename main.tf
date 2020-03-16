variable "aws_region" {
  default = "us-west-2"
}

provider "aws" {
  region = var.aws_region
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda_func.py"
  output_path = "lambda_func.zip"
}

resource "aws_lambda_function" "put_in_file" {
  filename         = "lambda_func.zip"
  function_name    = "put_string_in_a_file"
  role             = aws_iam_role.s3_access_role3.arn
  handler          = "lambda_func.handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.6"
}

resource "aws_iam_role" "s3_access_role3" {
  name               = "s3_access_role3"
  assume_role_policy = file("assumerolepolicy.json")
}

data "aws_iam_policy_document" "s3_policy_doc" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = [
      "arn:aws:s3:::the-bucket-head",
    ]
  }
  statement {
    actions = [
      "logs:*",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

resource "aws_iam_policy" "policy3" {
  name        = "test-policy3"
  description = "A test policy 3"
  path        = "/"
  policy      = data.aws_iam_policy_document.s3_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "test-attach3" {
  role       = aws_iam_role.s3_access_role3.name
  policy_arn = aws_iam_policy.policy3.arn
}

resource "aws_cloudwatch_event_rule" "every_hour" {
  name                = "every-hour-rule"
  description         = "Fires every hour"
  schedule_expression = "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "update_file_every_hour" {
  rule      = aws_cloudwatch_event_rule.every_hour.name
  target_id = "put_a_file"
  arn       = aws_lambda_function.put_in_file.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_put_file" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.put_in_file.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_hour.arn
}



output "arn" {
  value = aws_iam_role.s3_access_role3.arn
}
