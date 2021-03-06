data "aws_iam_policy_document" "lambda_assume_policy" {
  statement {
    sid    = "AzkabanLambdaAssumeRolePolicy"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      identifiers = [
        "lambda.amazonaws.com",
      ]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "lambda_manage_mysql_user" {
  name               = "azkaban_lambda_manage_mysql_user"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_manage_mysql_user_vpcaccess" {
  role       = aws_iam_role.lambda_manage_mysql_user.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "aws_iam_policy_document" "lambda_manage_mysql_user" {
  statement {
    sid    = "AllowUpdatePassword"
    effect = "Allow"
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:TagResource",
      "secretsmanager:ListSecretVersionIds"

    ]
    resources = [
      aws_secretsmanager_secret.azkaban_master_password.arn,
      aws_secretsmanager_secret.azkaban_webserver_password.arn,
      aws_secretsmanager_secret.azkaban_executor_password.arn
    ]
  }
}

resource "aws_iam_role_policy" "lambda_manage_mysql_user" {
  role   = aws_iam_role.lambda_manage_mysql_user.name
  policy = data.aws_iam_policy_document.lambda_manage_mysql_user.json
}
