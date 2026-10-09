resource "aws_sns_topic" "remediation_notifications" {
  #checkov:skip=CKV_AWS_26:Topic carries remediation notifications only for now; 

  name = local.remediation_topic_name
}
