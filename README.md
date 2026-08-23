# Cloud Security Automation Pipeline

A cloud security project built with Terraform on AWS. This repo is a work in progress — the scope and final architecture are still being defined.

## Current status

**Phase 1 complete:** Remote Terraform backend.

- S3 bucket for remote state, with versioning and encryption
- Native S3 locking enabled (`use_lockfile = true`, Terraform ≥ 1.5.0)

More components (detection, automated response, CI/CD) will be added incrementally. This README will be updated as the architecture solidifies.

## Requirements

- Terraform ≥ 1.5.0
- An AWS account with credentials configured locally

## Local setup

Terraform reads AWS credentials via the standard AWS credential chain. Make sure your local AWS CLI profile is authenticated (via `aws sso login`, `aws configure`, or any other method), then export it before running Terraform:

```bash
export AWS_PROFILE=<your-profile>
terraform plan
```

### Backend configuration

The S3 backend is defined with a partial configuration (`providers.tf`) to avoid hardcoding sensitive values. Copy the example file and fill in your own bucket, table, and region:

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

## Structure

```
.
├── main.tf                   # Core resources
├── data.tf                   # Data sources
├── providers.tf               # Provider config + partial backend block
├── s3_backend.tf              # Backend infrastructure (S3)
├── outputs.tf
├── variables.tf
├── backend.hcl.example        # Backend config template (copy to backend.hcl)
└── terraform.tfvars.example   # Variables template
```

## License

Personal portfolio project — no license specified yet.
