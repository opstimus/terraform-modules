# DynamoDB Table Module

## Description

This Terraform module creates an AWS DynamoDB table with configurable attributes, including hash and range keys, additional attributes, TTL, and global secondary indexes. It also supports enabling DynamoDB Streams.

## Requirements

| Name      | Version   |
|-----------|-----------|
| terraform | >= 1.3.0  |
| aws       | >= 4.0    |

## Providers

| Name  | Version |
|-------|---------|
| aws   | >= 4.0  |

## Inputs

| Name                    | Description                             | Type   | Default     | Required |
|-------------------------|-----------------------------------------|--------|-------------|:--------:|
| project                 | Project name                            | string | -           |   yes    |
| environment             | Environment name                        | string | -           |   yes    |
| name                    | Table name                              | string | -           |   yes    |
| hash_key                | Hash key attribute name                 | string | "id"        |    no    |
| hash_key_type           | Hash key attribute type (S, N, B)       | string | "S"         |    no    |
| range_key               | Range key attribute name                | string | "sk"        |    no    |
| range_key_type          | Range key attribute type (S, N, B)      | string | "S"         |    no    |
| additional_attributes   | List of additional attributes           | list(object({ name = string, type = string })) | []        |    no    |
| ttl_attribute           | Enable TTL when this parameter is defined | string | null      |    no    |
| global_secondary_indexes| List of global secondary indexes        | list(any) | []         |    no    |
| enable_stream           | Enable DynamoDB stream                  | bool   | false       |    no    |
| stream_view_type        | Stream view type (NEW_IMAGE, OLD_IMAGE, etc.) | string | "NEW_IMAGE" |    no    |

## Outputs

| Name                | Description                       |
|---------------------|-----------------------------------|
| dynamodb_table_arn  | The ARN of the DynamoDB table     |
| dynamodb_stream_arn | The ARN of the DynamoDB stream    |

## Usage examples

### Basic DynamoDB Table Setup

This example shows how to use the DynamoDB Table module to create a table with a specified name, hash key, and range key.

```hcl
module "dynamodb_table" {
  source                = "github.com/opstimus/terraform-aws-dynamodb?ref=v<RELEASE>"

  project               = "my-project"
  environment           = "dev"
  name                  = "my-table"
  hash_key              = "pk"
  range_key             = "sk"
  additional_attributes = [
    {
      name = "attribute1"
      type = "S"
    }
  ]
  ttl_attribute         = "ttl"
  enable_stream         = true
}
```
