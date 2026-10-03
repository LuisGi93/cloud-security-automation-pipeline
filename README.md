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

**Phase 3 in progress:** Terraform CD with GitHub Actions and a dedicated least-privilege role.

- GitHub Actions CD applying on push to `main`, using a saved plan (`plan -out` then `apply`)
- Separate CD role, assumable only from `refs/heads/main` of this repository (immutable owner/repo identity in the OIDC subject)
- CI role stays plan-only; CD role holds the write permissions, scoped per resource as they are added
- Native S3 locking enforced in both workflows (`use_lockfile=true` passed at `init`)
- Terraform pinned to the same version locally, in CI and in CD
- Hardened CODEOWNERS covering the `.github/` directory (including CODEOWNERS itself) and the provider lock file
- Direct pushes to `main` blocked for everyone, including admins (bypass limited to pull requests), since every push to `main` triggers an apply

More components (detection and automated response - GuardDuty, Security Hub, EventBridge, Lambda) will be added incrementally. This README will be updated as each phase lands.

## Requirements

- Terraform ≥ 1.10.0 (CI and CD pipelines run on 1.15.8)
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

> Note: the CI and CD roles can't manage their own IAM policies, so the initial bootstrap `apply` (and any change to the OIDC trust policies or to the roles' permissions) has to be run locally with admin credentials. See [ADR-002](docs/adr/002-oidc-least-privilege-immutable-identity.md).

## Structure

```
.
├── .github/
│   ├── CODEOWNERS
│   └── workflows/
│       ├── cd.yml
│       └── ci.yml
├── docs/
│   └── adr/
├── .gitignore
├── .terraform.lock.hcl
├── backend.hcl.example
├── data.tf
├── iam_cd_role.tf
├── iam_ci_role.tf
├── iam_cicd_common_policies.tf
├── locals.tf
├── main.tf
├── oidc.tf
├── outputs.tf
├── providers.tf
├── s3_backend.tf
├── variables.tf
└── terraform.tfvars.example
```

## Architecture

The pipeline uses GitHub Actions to validate Terraform changes before they are merged and to apply them after merge.

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

After merge, a second workflow applies the change:

```text
Merge to main
   │
   ▼
GitHub Actions (CD)
   ├── AWS STS / OIDC (assume CD role, main branch only)
   ├── Terraform init (S3 lockfile)
   ├── Terraform plan -out=tfplan
   └── Terraform apply tfplan
          │
          ▼
   IAM CD Role
   (least privilege, apply)
          │
          ├── Terraform state read/write
          └── Managed resources
```

## Architecture Decision Records

Security and architecture decisions are documented as ADRs under [`docs/adr/`](docs/adr/).

| ADR | Title | Status |
|-----|-------|--------|
| [001](docs/adr/001-protect-aws-access-from-untrusted-pull-requests.md) | Protect AWS access from untrusted pull requests | Accepted |
| [002](docs/adr/002-oidc-least-privilege-immutable-identity.md) | Use OIDC with least-privilege AWS trust and immutable repository identity | Accepted |

## License

Personal portfolio project - no license specified yet.
