resource "aws_iam_role" "github_actions_ci" {
  name               = "github-actions-ci-cloud-security-pipeline"
  assume_role_policy = data.aws_iam_policy_document.github_actions_trust.json
}

data "aws_iam_policy_document" "github_actions_trust" {
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
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:pull_request"]
    }
  }
}

data "aws_iam_policy_document" "github_actions_ci_plan_permissions" {
  statement {
    sid    = "TerraformStateBucketRead"
    effect = "Allow"

    actions = [
      "s3:GetBucketAccelerateConfiguration",
      "s3:GetBucketAcl",
      "s3:GetBucketCors",
      "s3:GetBucketEncryption",
      "s3:GetBucketLifecycleConfiguration",
      "s3:GetBucketLogging",
      "s3:GetBucketPolicy",
      "s3:GetBucketReplication",
      "s3:GetBucketRequestPayment",
      "s3:GetBucketTagging",
      "s3:GetBucketVersioning",
      "s3:GetBucketWebsite",
      "s3:ListBucket",
      "s3:GetBucketPublicAccessBlock"
    ]

    resources = [aws_s3_bucket.s3_backend.arn]
  }

  statement {
    sid       = "TerraformStateLockfileWrite"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.s3_backend.arn}/${var.state_key}.tflock"]
  }

  statement {
    sid    = "TerraformStateObjectRead"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.s3_backend.arn}/${var.state_key}"
    ]
  }

  statement {
    sid    = "TerraformStateLockfileRead"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.s3_backend.arn}/${var.state_key}.tflock"
    ]
  }

  statement {
    sid       = "TerraformStateLockfileDelete"
    effect    = "Allow"
    actions   = ["s3:DeleteObject"]
    resources = ["${aws_s3_bucket.s3_backend.arn}/${var.state_key}.tflock"]
  }

  statement {
    sid    = "IAMRoleRead"
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies"
    ]
    resources = [aws_iam_role.github_actions_ci.arn]
  }

  statement {
    sid    = "OIDCProviderRead"
    effect = "Allow"
    actions = [
      "iam:GetOpenIDConnectProvider"
    ]
    resources = [aws_iam_openid_connect_provider.github_actions.arn]
  }
}

resource "aws_iam_role_policy" "github_actions_ci_permissions" {
  name   = "terraform-ci-permissions"
  role   = aws_iam_role.github_actions_ci.id
  policy = data.aws_iam_policy_document.github_actions_ci_plan_permissions.json
}
