# Step Functions State Machine Module

## Description

This Terraform module provisions an AWS Step Functions state machine. The ASL
definition and the execution IAM role are supplied by the caller, so the module
stays generic — it only bakes the `${project}-${environment}-${name}` naming
convention and wires optional CloudWatch Logs logging and X-Ray tracing.

Logging is **off by default** (`logging_configuration = null`) to match how the
existing `divi-stg` state machines run; pass a `logging_configuration` object to
turn it on.

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.3.0 |
| aws       | >= 6.0   |

## Providers

| Name | Version  |
|------|----------|
| aws  | >= 6.0   |

## Inputs

| Name                  | Description                                                        | Type                                                            | Default      | Required |
|-----------------------|--------------------------------------------------------------------|----------------------------------------------------------------|--------------|:--------:|
| project               | Project name                                                      | `string`                                                       | -            |   yes    |
| environment           | Environment name                                                  | `string`                                                       | -            |   yes    |
| name                  | State machine name                                                | `string`                                                       | -            |   yes    |
| definition            | ASL JSON definition of the state machine                          | `string`                                                       | -            |   yes    |
| role_arn              | ARN of the IAM role the state machine assumes at execution time   | `string`                                                       | -            |   yes    |
| type                  | State machine type (`STANDARD` or `EXPRESS`)                       | `string`                                                       | `"STANDARD"` |    no    |
| logging_configuration | CloudWatch Logs config; `null` disables logging entirely          | `object({ log_destination, include_execution_data, level })`  | `null`       |    no    |
| tracing_enabled       | Enable AWS X-Ray tracing                                          | `bool`                                                         | `false`      |    no    |
| tags                  | A map of tags to assign to the resource                           | `map(string)`                                                  | `{}`         |    no    |

## Outputs

| Name               | Description                    |
|--------------------|--------------------------------|
| state_machine_arn  | The ARN of the state machine   |
| state_machine_name | The name of the state machine  |

## Usage examples

### Basic Usage Example

```hcl
module "pipeline" {
  source      = "git::https://github.com/opstimus/terraform-modules.git//modules/aws-sfn-state-machine?ref=aws-sfn-state-machine/v<RELEASE>"
  project     = "my-project"
  environment = "production"
  name        = "pipeline"
  role_arn    = module.pipeline_role.role_arn
  definition  = file("${path.module}/definitions/pipeline.asl.json")

  tags = {
    Project     = "my-project"
    Environment = "production"
  }
}
```

### With logging enabled

```hcl
module "pipeline" {
  source      = "git::https://github.com/opstimus/terraform-modules.git//modules/aws-sfn-state-machine?ref=aws-sfn-state-machine/v<RELEASE>"
  project     = "my-project"
  environment = "production"
  name        = "pipeline"
  role_arn    = module.pipeline_role.role_arn
  definition  = file("${path.module}/definitions/pipeline.asl.json")

  logging_configuration = {
    log_destination        = "${module.pipeline_log_group.log_group_arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }

  tags = {
    Project     = "my-project"
    Environment = "production"
  }
}
```
