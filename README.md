# Cloud Security Automation Pipeline

A security-focused AWS/Terraform automation project developed incrementally to demonstrate secure cloud infrastructure. This repo is a work in progress - the scope and final architecture are still being defined.

## Current status

**Phase 1 complete:** Remote Terraform backend.

- S3 bucket for remote state, with versioning and encryption
- Native S3 locking enabled (`use_lockfile = true`)

**Phase 2 complete:** Secure Terraform CI with GitHub Actions and AWS OIDC.

The project currently includes:

- GitHub Actions CI running Terraform checks on pull requests
- AWS IAM OIDC federation for GitHub Actions, avoiding long-lived AWS credentials
- Least-privilege IAM permissions for the Terraform CI role
- Same-repository pull request restriction in the OIDC trust policy
- Protection against untrusted fork pull requests accessing AWS credentials
- CODEOWNERS and branch protection for security-sensitive files
- Checkov security scanning as part of CI
- Architecture Decision Records documenting the main security decisions

More components (detection and automated response - GuardDuty, Security Hub, EventBridge, Lambda) will be added incrementally. This README will be updated as each phase lands.

## Requirements

- Terraform ≥ 1.5.0 (CI pipeline runs on 1.9.0)
- An AWS account

## Local setup

Terraform reads AWS credentials via the standard AWS credential chain. Make sure your local AWS CLI profile is authenticated (via `aws sso login`, `aws configure`, or any other method), then export it before running Terraform:

```bash
export AWS_PROFILE=<your-profile>
terraform plan
```

### Backend configuration

The S3 backend is defined with a partial configuration (`providers.tf`) to avoid hardcoding sensitive values. Copy the example file and fill in your own bucket, region, and profile:

```bash
cp backend.hcl.example backend.hcl
```

Then initialize Terraform pointing to that file:

```bash
terraform init -backend-config=backend.hcl
```

`backend.hcl` is gitignored and should never be committed.

### Variables

Copy the example variables file and adjust as needed:

```bash
cp terraform.tfvars.example terraform.tfvars
```

> Note: the CI role can't manage its own IAM policy before it exists, so the initial bootstrap `apply` (and any change to the OIDC trust policy) has to be run locally with admin credentials — see [ADR-002](docs/adr/002-oidc-least-privilege-immutable-identity.md).

## Structure

```
.
├── .github/
│   ├── CODEOWNERS
│   └── workflows/
│       └── ci.yml
├── docs/
│   └── adr/
├── backend.hcl.example
├── data.tf
├── iam_ci_role.tf
├── main.tf
├── oidc.tf
├── outputs.tf
├── providers.tf
├── s3_backend.tf
├── variables.tf
└── terraform.tfvars.example
```

## Architecture

The current pipeline uses GitHub Actions to validate Terraform changes before they are merged.

```text
Developer
   │
   ▼
GitHub Pull Request
   │
   ▼
GitHub Actions
   ├── Terraform fmt
   ├── Checkov
   ├── AWS STS / OIDC (assume CI role)
   ├── Terraform init
   ├── Terraform validate
   └── Terraform plan
          │
          ▼
   IAM CI Role
   (least privilege, plan-only)
          │
          └── Terraform state access
                    │
                    ▼
                 S3 Backend
```

## Architecture Decision Records

Security and architecture decisions are documented as ADRs under [`docs/adr/`](docs/adr/).

| ADR | Title | Status |
|-----|-------|--------|
| [001](docs/adr/001-protect-aws-access-from-untrusted-pull-requests.md) | Protect AWS access from untrusted pull requests | Accepted |
| [002](docs/adr/002-oidc-least-privilege-immutable-identity.md) | Use OIDC with least-privilege AWS trust and immutable repository identity | Accepted |

## License

Personal portfolio project - no license specified yet.
