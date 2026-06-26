# AWS MSK Cluster Module

## Description

This Terraform module provisions an Amazon MSK (Managed Streaming for Apache Kafka) provisioned cluster, along with a dedicated security group for the broker nodes. It supports encryption in transit and at rest, SASL/IAM, SASL/SCRAM and TLS client authentication, an optional custom cluster configuration, broker log delivery to CloudWatch and S3, and Prometheus open monitoring. The bootstrap broker string for the enabled access method is published to SSM Parameter Store.

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
| project | Project name | string | - | yes |
| environment | Environment name | string | - | yes |
| name | Service name | string | - | yes |
| vpc_id | VPC ID where the security group is created | string | - | yes |
| vpc_cidr | VPC CIDR allowed to reach the broker ports | string | - | yes |
| private_subnet_ids | Subnets the broker nodes are placed in | list(string) | - | yes |
| kafka_version | Apache Kafka version, e.g. 3.6.0 | string | - | yes |
| number_of_broker_nodes | Number of broker nodes (multiple of the AZ count) | number | 3 | no |
| instance_type | Broker instance type | string | kafka.m5.large | no |
| broker_volume_size | EBS volume size (GiB) per broker | number | 100 | no |
| broker_provisioned_throughput | Provisioned EBS throughput (MiB/s) per broker; 0 disables | number | 0 | no |
| enhanced_monitoring | DEFAULT, PER_BROKER, PER_TOPIC_PER_BROKER or PER_TOPIC_PER_PARTITION | string | DEFAULT | no |
| storage_mode | LOCAL or TIERED | string | LOCAL | no |
| kms_key_arn | KMS key ARN for encryption at rest (null = AWS-managed key) | string | null | no |
| encryption_in_transit_client_broker | TLS, TLS_PLAINTEXT or PLAINTEXT | string | TLS | no |
| encryption_in_transit_in_cluster | Encrypt data in transit between brokers | bool | true | no |
| enable_sasl_iam | Enable SASL/IAM authentication (port 9098) | bool | false | no |
| enable_sasl_scram | Enable SASL/SCRAM authentication (port 9096) | bool | false | no |
| enable_tls_auth | Enable TLS mutual authentication | bool | false | no |
| tls_certificate_authority_arns | ACM Private CA ARNs for TLS auth | list(string) | [] | no |
| enable_unauthenticated | Allow unauthenticated access | bool | false | no |
| scram_secret_association_arns | Secrets Manager ARNs to associate for SASL/SCRAM | list(string) | [] | no |
| configuration_server_properties | MSK configuration (server.properties); empty disables | string | "" | no |
| log_group | CloudWatch log group for broker logs; empty disables | string | "" | no |
| logs_s3_bucket | S3 bucket for broker logs; empty disables | string | "" | no |
| logs_s3_prefix | Prefix for broker logs delivered to S3 | string | "" | no |
| enable_open_monitoring | Enable Prometheus open monitoring | bool | false | no |
| open_monitoring_jmx_exporter | Enable JMX exporter on brokers (port 11001) | bool | true | no |
| open_monitoring_node_exporter | Enable node exporter on brokers (port 11002) | bool | true | no |
| enable_storage_autoscaling | Auto-grow broker EBS storage via Application Auto Scaling | bool | false | no |
| broker_storage_max_size | Max broker EBS size (GiB) autoscaling may grow to; must be >= broker_volume_size | number | 0 | no |
| broker_storage_target_utilization | Storage-utilization % that triggers a scale-up | number | 70 | no |
| tags | A map of tags to assign to the resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_arn | ARN of the MSK cluster |
| cluster_name | Name of the MSK cluster |
| security_group_id | ID of the security group created for the brokers |
| bootstrap_brokers | Bootstrap broker string matching the enabled access method |
| bootstrap_brokers_tls | TLS bootstrap broker connection string |
| bootstrap_brokers_sasl_iam | SASL/IAM bootstrap broker connection string |
| bootstrap_brokers_sasl_scram | SASL/SCRAM bootstrap broker connection string |
| zookeeper_connect_string | ZooKeeper connection string (empty for KRaft clusters) |

The bootstrap broker string is also written to SSM Parameter Store at
`/<project>/<environment>/<name>/central/msk/bootstrap-brokers`.

## Usage examples

### Example 1: Basic cluster with IAM authentication

```hcl
module "msk" {
  source                 = "github.com/opstimus/terraform-aws-msk-cluster?ref=v<RELEASE>"
  project                = "my-project"
  environment            = "dev"
  name                   = "events"
  vpc_id                 = "vpc-0abcd1234efgh5678"
  vpc_cidr               = "172.16.0.0/16"
  private_subnet_ids     = ["subnet-0aaa", "subnet-0bbb", "subnet-0ccc"]
  kafka_version          = "3.6.0"
  number_of_broker_nodes = 3
  instance_type          = "kafka.m5.large"
  broker_volume_size     = 100
  enable_sasl_iam        = true

  tags = {
    Project     = "my-project"
    Environment = "dev"
  }
}
```

### Example 2: SCRAM auth with custom configuration and CloudWatch logs

```hcl
module "msk" {
  source                          = "github.com/opstimus/terraform-aws-msk-cluster?ref=v<RELEASE>"
  project                         = "my-project"
  environment                     = "prod"
  name                            = "events"
  vpc_id                          = "vpc-0abcd1234efgh5678"
  vpc_cidr                        = "172.16.0.0/16"
  private_subnet_ids              = ["subnet-0aaa", "subnet-0bbb", "subnet-0ccc"]
  kafka_version                   = "3.6.0"
  number_of_broker_nodes          = 3
  instance_type                   = "kafka.m5.large"
  broker_volume_size              = 250
  storage_mode                    = "TIERED"
  kms_key_arn                     = "arn:aws:kms:eu-west-1:111122223333:key/abcd"
  enable_sasl_scram               = true
  scram_secret_association_arns   = ["arn:aws:secretsmanager:eu-west-1:111122223333:secret:AmazonMSK_user-AbCdEf"]
  configuration_server_properties = "auto.create.topics.enable=false\ndefault.replication.factor=3\nmin.insync.replicas=2\n"
  log_group                       = "/my-project/prod/events/msk"
  enhanced_monitoring             = "PER_TOPIC_PER_BROKER"
  enable_open_monitoring          = true

  tags = {
    Project     = "my-project"
    Environment = "prod"
  }
}
```

## Validation

The module fails fast at **plan** time (via resource preconditions) instead of erroring mid-apply if:

- No access method is selected — you must set at least one of `enable_sasl_iam`, `enable_sasl_scram`, `enable_tls_auth`, or explicitly `enable_unauthenticated = true`. This prevents accidentally creating an unauthenticated cluster from the defaults.
- SASL is enabled (`enable_sasl_iam` / `enable_sasl_scram`) but `encryption_in_transit_client_broker` is `PLAINTEXT` — SASL requires `TLS` or `TLS_PLAINTEXT`.
- `enable_tls_auth = true` but `tls_certificate_authority_arns` is empty.
- `private_subnet_ids` has fewer than two subnets, or `number_of_broker_nodes` is not a multiple of the number of subnets.

## Notes

- Security group ingress is opened only for the broker ports relevant to the enabled encryption/authentication (9092 PLAINTEXT, 9094 TLS, 9096 SASL/SCRAM, 9098 SASL/IAM) from `vpc_cidr`. When `enable_open_monitoring` is on, the matching exporter ports (11001 JMX, 11002 node) are opened from `vpc_cidr` as well.
- `log_group` expects an existing CloudWatch log group name (e.g. created with `terraform-aws-log-group`).
- AWS constraints to be aware of when updating: `broker_volume_size` can only be increased, `number_of_broker_nodes` can only be increased, and some changes replace the cluster.
- **Storage autoscaling caveat:** once a scale-up has grown the volume past `broker_volume_size`, a later plan would try to shrink it back (which AWS rejects). After autoscaling has fired, raise `broker_volume_size` to the current size, or add an `ignore_changes` on the volume size, to keep plans clean.
