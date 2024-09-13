# SQS Module

## Description

This Terraform module provisions an AWS SQS queue and optional dead-letter queue (DLQ) with customizable configurations like message retention, visibility timeout, and FIFO support. It also creates IAM policies, SSM parameters, and includes support for high-throughput mode on FIFO queues.

## Requirements

| Name      | Version   |
|-----------|-----------|
| terraform | >= 1.3.0  |
| aws       | >= 4.0    |

## Providers

| Name | Version |
|------|---------|
| aws  | >= 4.0  |

## Inputs

| Name                        | Description                                                                                                     | Type     | Default  | Required |
|-----------------------------|-----------------------------------------------------------------------------------------------------------------|----------|----------|:--------:|
| project                     | Project name                                                                                                    | `string` | -        |   yes    |
| environment                 | Environment name                                                                                                | `string` | -        |   yes    |
| name                        | Service name                                                                                                    | `string` | -        |   yes    |
| enable_dlq                  | Enable dead-letter queue                                                                                         | `bool`   | `false`  |    no    |
| enable_fifo                 | Enable FIFO queue                                                                                               | `bool`   | `false`  |    no    |
| visibility_timeout_seconds   | The visibility timeout for the queue                                                                            | `number` | `30`     |    no    |
| message_retention_seconds    | The number of seconds Amazon SQS retains a message                                                              | `number` | `345600` |    no    |
| max_message_size             | The limit on how many bytes a message can contain                                                               | `number` | `262144` |    no    |
| delay_seconds                | The delay in seconds for message delivery                                                                       | `number` | `0`      |    no    |
| receive_wait_time_seconds    | The time a `ReceiveMessage` call will wait for a message before returning (long polling)                        | `number` | `0`      |    no    |
| policy                      | Custom SQS policy                                                                                               | `string` | `null`   |    no    |
| max_receive_count            | The number of times a message is received from a queue before being moved to the dead-letter queue               | `number` | `5`      |    no    |
| enable_high_throughput       | Enable high throughput mode for FIFO queues                                                                     | `bool`   | `false`  |    no    |
| message_retention_seconds_dlq| The number of seconds Amazon SQS retains a message in the DLQ                                                   | `number` | `1209600`|    no    |

## Outputs

| Name         | Description                            |
|--------------|----------------------------------------|
| sqs_arn      | The ARN of the SQS queue               |
| sqs_url      | The URL of the SQS queue               |
| dlq_sqs_arn  | The ARN of the dead-letter queue (DLQ) |
| dlq_sqs_url  | The URL of the dead-letter queue (DLQ) |

## Usage examples

### Basic SQS queue with optional DLQ

```hcl
module "sqs" {
  source  = "https://github.com/opstimus/terraform-aws-sqs?ref=v<RELEASE>"

  project                      = "my-project"
  environment                  = "production"
  name                         = "service-queue"
  enable_fifo                  = true
  enable_dlq                   = true
  visibility_timeout_seconds   = 60
  message_retention_seconds    = 1209600
  max_receive_count            = 5
  enable_high_throughput       = true
}
```