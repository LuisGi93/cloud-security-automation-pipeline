locals {
  remediation_topic_name = "remediation-notifications"
  remediation_topic_arn  = "arn:aws:sns:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${local.remediation_topic_name}"

  remediation_sg_rule_name = "csap-sg-ingress-authorized"
  remediation_sg_rule_arn  = "arn:aws:events:${var.aws_region}:${data.aws_caller_identity.current.account_id}:rule/${local.remediation_sg_rule_name}"
}
