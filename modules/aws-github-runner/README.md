# GitHub Actions Self-Hosted Runner on EC2

## Description

This Terraform module provisions an EC2 instance configured as a GitHub Actions self-hosted runner. The module creates an IAM role with permissions to access AWS Secrets Manager for retrieving the GitHub token, attaches additional IAM policies, and configures the instance to automatically register with the specified GitHub repository.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 6.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project | Project name | `string` | - | yes |
| environment | Environment name | `string` | - | yes |
| name | Name identifier for the runner (e.g., 'base', 'app') | `string` | - | yes |
| vpc_id | VPC ID where the runner will be deployed | `string` | - | yes |
| subnet_id | Subnet ID for the runner instance | `string` | - | yes |
| deploy_region | AWS region for deployment | `string` | - | yes |
| github_repository | GitHub repository in format owner/repo | `string` | - | yes |
| instance_type | EC2 instance type | `string` | "t3.small" | no |
| additional_policy_arns | List of additional IAM policy ARNs to attach to the runner role | `list(string)` | [] | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | The ID of the GitHub runner EC2 instance |

## Example Usage

```hcl
module "github_runner" {
  source = "github.com/opstimus/terraform-aws-github-runner?ref=v<RELEASE>"

  project           = "my-project"
  environment       = "stg"
  name              = "base"
  vpc_id            = module.vpc.vpc_id
  subnet_id         = split(",", module.vpc.private_subnets)[0]
  deploy_region     = "us-east-2"
  github_repository = "my-org/my-repo"
  instance_type     = "t3.small"
  additional_policy_arns = [
    "arn:aws:iam::123456789012:policy/TerraformStateAccess",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation"
  ]
}
```

## Notes

- The module automatically retrieves the GitHub token from AWS Secrets Manager using the secret name `github/runner/token`
- The GitHub token must be stored in AWS Secrets Manager before deploying the module
- For fine-grained tokens, the token must have "Administration" repository permissions (write) to register runners
- The runner is configured to run in the foreground (not as a service) since it's intended for temporary use
- The instance uses Ubuntu 24.04 LTS AMI
- The runner name follows the pattern: `${project}-${environment}-${name}-github-runner`
