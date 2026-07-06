# terraform-modules

Monorepo of opstimus Terraform modules, organized by provider.

## Layout

Modules live flat under `modules/<key>/`. The key carries the provider prefix
(`aws-vpc`, `oci-vcn`); provider-less modules keep their bare name (`postgresql`).

## Usage

```hcl
module "vpc" {
  source = "git::https://github.com/opstimus/terraform-modules.git//modules/aws-vpc?ref=aws-vpc/v2.2.1"
}
```

Pin `?ref=` to a per-module tag of the form `<key>/vX.Y.Z`.

## Modules

Each module lives at `modules/<key>/` and is versioned independently. Pin `?ref=`
to that module's own tag (`<key>/vX.Y.Z`).

### AWS

`aws-acm`, `aws-alb`, `aws-api-gateway`, `aws-aurora`, `aws-aurora-dsql`, `aws-dynamodb`, `aws-ec2-instance`, `aws-ecr`, `aws-ecs-autoscaling-scheduled`, `aws-ecs-autoscaling-standard`, `aws-ecs-cluster`, `aws-ecs-service`, `aws-ecs-task`, `aws-efs`, `aws-github-runner`, `aws-iam-role`, `aws-iam-user`, `aws-kms`, `aws-lambda`, `aws-log-group`, `aws-rds`, `aws-s3-bucket`, `aws-secret`, `aws-ses`, `aws-site-to-site-vpn`, `aws-sns`, `aws-sqs`, `aws-target-group`, `aws-task-definition`, `aws-vpc`

### OCI

`oci-backend-set`, `oci-container-instances`, `oci-instance`, `oci-kms-key`, `oci-kms-vault`, `oci-lb`, `oci-postgresql`, `oci-redis`, `oci-vcn`

### Other

`mongodb-advance`, `postgresql`
