locals {
  remediation_topic_name = "remediation-notifications"

  remediation_topic_arn = join(":", [
    "arn",
    "aws",
    "sns",
    var.aws_region,
    data.aws_caller_identity.current.account_id,
    local.remediation_topic_name
  ])
}
