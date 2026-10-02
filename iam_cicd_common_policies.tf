

data "aws_iam_policy_document" "terraform_state_read" {
  statement {
    sid    = "TerraformStateBucketRead"
    effect = "Allow"

    actions = [
      "s3:GetAccelerateConfiguration",
      "s3:GetBucketAcl",
      "s3:GetBucketCors",
      "s3:GetEncryptionConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetBucketLogging",
      "s3:GetBucketPolicy",
      "s3:GetReplicationConfiguration",
      "s3:GetBucketRequestPayment",
      "s3:GetBucketObjectLockConfiguration",
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
    resources = [
      aws_iam_role.github_actions_ci.arn,
      aws_iam_role.github_actions_cd.arn
    ]
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


