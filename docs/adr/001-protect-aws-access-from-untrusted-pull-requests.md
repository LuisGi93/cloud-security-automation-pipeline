# ADR 1 - Protect AWS access from untrusted pull requests

**Status:** Accepted

## Context

*Github Actions is connected with my AWS account -> something external that can do actions in my AWS account -> Can someone do a rogue PR and inject code that can execute on AWS?*

The repository is public because it is used to demonstrate Cloud Security and DevSecOps practices.

GitHub Actions is used to automate infrastructure validation, including Terraform operations that require AWS access.

Because the repository is public, external contributors can submit pull requests containing untrusted code.

If that code were executed by a privileged GitHub Actions workflow, it could potentially obtain AWS credentials and perform unauthorized operations. The CI pipeline therefore requires an explicit trust boundary between internal pull requests and untrusted external contributions.

## Decision

### 1. Restrict CI execution to only my branches

The AWS-authenticated job runs only when:

[ci.yml](https://github.com/LuisGi93/cloud-security-automation-pipeline/blob/main/.github/workflows/ci.yml)

```yaml
if: github.event.pull_request.head.repo.full_name == github.repository
```

This will only happen when the PR comes from a branch of the repository.

### 2. Use `pull_request`

The workflow uses `pull_request` instead of `pull_request_target` so that pull-request code is not executed in the privileged context of the target repository.

### 3. Harden GitHub repository settings

* Require approval for workflows from external contributors.
* Set workflow permissions to read-only by default.
* Use [CODEOWNERS](https://github.com/LuisGi93/cloud-security-automation-pipeline/blob/main/.github/CODEOWNERS) to protect Terraform infrastructure and GitHub Actions workflow files.

## Consequences

### Positive

* Fork-based pull requests are blocked from the AWS-authenticated path by two independent controls (repo-match guard + external contributor approval).
* Changes to Terraform and workflow definitions require code-owner review.

### Negative

* Repository configuration and CODEOWNERS require maintenance.
* The CI workflow has less flexibility because AWS access is deliberately restricted to trusted repository contexts.

### Validation

Fork-blocking behavior has not been empirically validated against a real external fork; testing would require a second GitHub account. The design relies on GitHub's documented behavior for `pull_request` scope and the repo-match guard, not on live adversarial testing.

### Deferred

Terraform apply from GitHub Actions is not implemented in the current CI workflow. The current pipeline is limited to validation, security scanning and plan. A future deployment workflow would require a separate trust boundary and explicit approval.
