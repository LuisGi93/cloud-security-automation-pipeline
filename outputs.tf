output "github_actions_ci_role_arn" {
  description = "ARN of the IAM role assumed by GitHub Actions via OIDC. Used in the workflow YAML."
  value       = aws_iam_role.github_actions_ci.arn
}
