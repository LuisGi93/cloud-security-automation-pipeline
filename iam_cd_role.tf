resource "aws_iam_role" "github_actions_cd" {
  name               = "github-actions-cd-cloud-security-pipeline"
  assume_role_policy = data.aws_iam_policy_document.github_actions_cd_trust.json
}

data "aws_iam_policy_document" "github_actions_cd_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:ref:refs/heads/main"]
    }
  }
}

data "aws_iam_policy_document" "github_actions_cd_permissions" {
  source_policy_documents = [data.aws_iam_policy_document.terraform_state_read.json]

  statement {
    sid       = "TerraformStateObjectWrite"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.s3_backend.arn}/${var.state_key}"]
  }

  statement {
    sid    = "SnsTopicManagement"
    effect = "Allow"

    actions = [
      "sns:CreateTopic",
      "sns:TagResource"
    ]
    resources = [local.remediation_topic_arn]
  }


}

resource "aws_iam_role_policy" "github_actions_cd_permissions" {
  name   = "terraform-cd-permissions"
  role   = aws_iam_role.github_actions_cd.id
  policy = data.aws_iam_policy_document.github_actions_cd_permissions.json
}
