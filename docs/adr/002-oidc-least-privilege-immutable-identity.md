# ADR 2 - Use OIDC with least-privilege AWS trust and immutable repository identity

**Status:** Accepted

## Context

*Don't want to give eternal passwords. Moreover, prefer not to use password or as limited as possible.*

*A password is a weakness and is hard to maintain and renew periodically. I also see every day how often passwords get leaked because some incident happen so I want to find the most secure and soft way to enable authentication between my Github repository and my AWS account. Also in case something happens it should have the fewest permissions possible so the blast radius is limited.*

Static long-lived AWS credentials stored as GitHub Secrets represent a persistent liability: they require manual rotation, are vulnerable to accidental exposure in logs or forks, and give no information about specific execution context. OIDC federation eliminates the need to store long-lived AWS credentials, removing the risk associated with credential leakage and manual rotation.

## Decision

### 1. OIDC and Immutable Repository Identity

After evaluating different authentication mechanisms between GitHub Actions and AWS, I decided to implement OIDC. This establishes a direct trust relationship between AWS and GitHub without static keys, exchanging short-lived credentials via AWS STS.

I also enabled an additional security measure ["Immutable subject claims for GitHub Actions OIDC tokens"](https://github.blog/changelog/2026-04-23-immutable-subject-claims-for-github-actions-oidc-tokens/). It is a feature that has all repositories created after July 15, 2026. With it, even if my GitHub account or repository were deleted and later recreated by a third party with the exact same name, authentication would fail. GitHub assigns an immutable unique numerical ID to the owner and repository (`owner@owner_id/repo@repo_id`), acting as an immutable identifier.

### 2. Least-Privilege IAM Policy & Restricted Execution

I implemented least-privilege access across two dimensions:

* **What GitHub Actions can do:** I ran `TF_LOG=DEBUG terraform plan` to inspect and get a baseline of the AWS API calls executed during planning. I then mapped those calls to a tightly scoped IAM policy for the CI role, ensuring it holds only the minimum required permissions.
* **Who can assume the role:** The trust policy is restricted so that only execution context from pull requests originating from my immutable repository identity can assume the role:

[iam_ci_role.tf](https://github.com/LuisGi93/cloud-security-automation-pipeline/blob/main/iam_ci_role.tf)

```hcl
condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:pull_request"]
}
```

Where `var.github_repo` defaults to:

[variables.tf](https://github.com/LuisGi93/cloud-security-automation-pipeline/blob/main/variables.tf)

```hcl
"LuisGi93@17405573/cloud-security-automation-pipeline@1338709143"
```

## Consequences

### Positive

* **No static credentials used:** Eliminates the risk of long-lived secrets getting leaked, logged, or needing manual rotation.
* **Minimized blast radius:** Drastically reduced attack surface and blast radius by enforcing least-privilege IAM policies and scoping the OIDC trust to `pull_request` events on an immutable repo ID.

### Negative

* **Chicken-and-egg problem:** Managing this CI role with Terraform creates a real "chicken and egg" problem. The role can't create or update itself before it exists, so the initial setup (and any big changes to the OIDC trust policy) has to be run locally using admin credentials.
* **Permission maintenance:** Since the IAM policy is restricted to the absolute minimum, adding new AWS resources to the Terraform stack means auditing the API calls first and updating the role permissions beforehand.

### Deferred

* Change `StringLike` to `StringEquals` in the OIDC trust policy. Since the subject claim value is an exact string match without wildcards, `StringEquals` is stricter and cleaner. While using `StringLike` here isn't a security vulnerability, locking it down further is better practice.
* The current least-privilege permission set reflects only the API calls required to plan the existing backend/IAM/OIDC resources. As GuardDuty, Security Hub, EventBridge, and Lambda resources are introduced (I hope), the role's permission set will require re-derivation using the same `TF_LOG=DEBUG` methodology - it is not yet representative of the project's full future footprint.
