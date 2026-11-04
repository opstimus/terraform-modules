# Egress Monitor Module

## Description

This Terraform module checks that private subnets can reach the internet. It runs one small Lambda function in each given subnet on a schedule (every 5 minutes by default). Each function fetches a probe URL and fails if it can't, and a CloudWatch alarm per subnet notifies an SNS topic when checks keep failing.

It catches anything that breaks outbound access from that subnet: a stopped or dead NAT, lost NAT forwarding rules, a wrong route, or a security group/NACL change. One function runs per subnet (and so per AZ), so each AZ's NAT path is checked separately.

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.3.0 |
| aws       | >= 6.0   |
| archive   | >= 2.0   |

## Inputs

| Name                | Description                                                        | Type           | Default                           | Required |
|---------------------|--------------------------------------------------------------------|----------------|-----------------------------------|:--------:|
| project             | Project name                                                       | `string`       | -                                 | yes      |
| environment         | Environment name                                                   | `string`       | -                                 | yes      |
| vpc_id              | VPC ID                                                             | `string`       | -                                 | yes      |
| subnet_ids          | Private subnet IDs to check (one probe per subnet)                 | `list(string)` | -                                 | yes      |
| alarm_sns_arn       | SNS topic ARN for the alarms                                       | `string`       | -                                 | yes      |
| probe_url           | URL each probe fetches                                             | `string`       | `"https://checkip.amazonaws.com"` | no       |
| schedule_expression | How often the probes run (alarm periods assume 5 minutes)          | `string`       | `"rate(5 minutes)"`               | no       |
| log_retention_days  | Log retention for the probe functions                              | `number`       | `14`                              | no       |
| tags                | Tags to assign to resources                                        | `map(string)`  | `{}`                              | no       |

## Outputs

| Name           | Description                       |
|----------------|-----------------------------------|
| function_names | Probe Lambda function names       |
| alarm_names    | Egress alarm names, one per subnet |

## Usage example

```hcl
module "egress_monitor" {
  source        = "git::https://github.com/opstimus/terraform-modules.git//modules/aws-egress-monitor?ref=aws-egress-monitor/v<RELEASE>"
  project       = "my-project"
  environment   = "production"
  vpc_id        = module.vpc.vpc_id
  subnet_ids    = split(",", module.vpc.private_subnets)
  alarm_sns_arn = module.sns_alarms.sns_arn
  tags = {
    Project     = "my-project"
    Environment = "production"
  }
}
```

## Notes

- An alarm fires when 2 of the last 3 five-minute checks fail (about 10 minutes of lost egress), and returns to OK when checks pass again.
- The alarm watches the Lambda service's own `Errors` metric, which Lambda publishes even when the subnet has no egress.
- The probe log line includes the egress IP returned by `checkip.amazonaws.com`, which shows the subnet's traffic going out through the expected NAT Elastic IP.
- If NATs are stopped on purpose (e.g. by a hibernation schedule), the probes fail and the alarms fire. Disable the alarm actions while hibernated, or don't use this module in those environments.
- Lambda VPC network interfaces can take a while to be released, so destroying this module may be slow.
