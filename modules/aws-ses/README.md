# AWS SES Identity Module

## Description

This Terraform module creates an AWS Simple Email Service (SES) identity. It supports creating either a domain identity or an email identity and will trigger domain verification when a domain identity is used.

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.3.0 |
| aws       | >= 6.0   |

## Providers

| Name | Version |
|------|---------|
| aws  | >= 6.0  |

## Inputs

| Name          | Description                                        | Type     | Default | Required |
|---------------|----------------------------------------------------|----------|---------|:--------:|
| `identity_type` | Type of identity to create: `domain` or `email`  | `string` | -       | yes      |
| `ses_domain`  | Domain to create/verify as SES identity (domain)   | `string` | -       | yes      |
| `ses_email`   | Email address to create as SES identity (email)    | `string` | -       | yes      |

Notes:
- Provide either `identity_type = "domain"` and `ses_domain`, or `identity_type = "email"` and `ses_email`.

## Outputs

| Name     | Description |
|----------|-------------|
| `ses_arn` | The ARN of the created SES identity |

## Usage examples

### Example: Create and verify a domain identity

```hcl
module "ses_identity" {
  source        = "github.com/opstimus/terraform-aws-ses?ref=v<RELEASE>" # replace with module source
  identity_type = "domain"
  ses_domain    = "example.com"
}
```

Note: The module triggers domain verification but does not create DNS records. To complete verification you must add the TXT verification record that AWS provides for the domain (or extend the module to create the record via Route53 or your DNS provider).

### Example: Create an email identity

```hcl
module "ses_email" {
  source        = "github.com/opstimus/terraform-aws-ses?ref=v<RELEASE>" # replace with module source
  identity_type = "email"
  ses_email     = "notify@example.com"
}
```

## Behaviour & Limitations

- When `identity_type = "domain"`, the module creates an `aws_ses_domain_identity` and an `aws_ses_domain_identity_verification` resource. You still need to publish the DNS verification TXT record for AWS to verify the domain.
- When `identity_type = "email"`, the module creates an `aws_ses_email_identity` for the provided email address. AWS will send a verification email to that address which must be confirmed by the recipient.

## License

See [LICENSE](LICENSE) for license details.
