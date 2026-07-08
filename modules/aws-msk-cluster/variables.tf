variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "name" {
  type        = string
  description = "Service name"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
  default     = {}
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the MSK security group is created."
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block allowed to reach the broker ports."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Subnets the broker nodes are placed in. Must match number_of_broker_nodes (or be a multiple of it across AZs)."
}

variable "kafka_version" {
  type        = string
  description = "Apache Kafka version for the cluster, e.g. 3.6.0."
}

variable "number_of_broker_nodes" {
  type        = number
  description = "Number of broker nodes. Must be a multiple of the number of subnets/AZs."
  default     = 3
}

variable "instance_type" {
  type        = string
  description = "Broker instance type, e.g. kafka.m5.large."
  default     = "kafka.m5.large"
}

variable "broker_volume_size" {
  type        = number
  description = "EBS volume size (GiB) per broker."
  default     = 100
}

variable "broker_provisioned_throughput" {
  type        = number
  description = "Provisioned EBS throughput (MiB/s) per broker. 0 disables provisioned throughput."
  default     = 0
}

variable "enhanced_monitoring" {
  type        = string
  description = "Level of CloudWatch metrics: DEFAULT, PER_BROKER, PER_TOPIC_PER_BROKER or PER_TOPIC_PER_PARTITION."
  default     = "DEFAULT"

  validation {
    condition     = contains(["DEFAULT", "PER_BROKER", "PER_TOPIC_PER_BROKER", "PER_TOPIC_PER_PARTITION"], var.enhanced_monitoring)
    error_message = "enhanced_monitoring must be one of DEFAULT, PER_BROKER, PER_TOPIC_PER_BROKER, PER_TOPIC_PER_PARTITION."
  }
}

variable "storage_mode" {
  type        = string
  description = "Storage tier for the brokers: LOCAL or TIERED."
  default     = "LOCAL"

  validation {
    condition     = contains(["LOCAL", "TIERED"], var.storage_mode)
    error_message = "storage_mode must be either LOCAL or TIERED."
  }
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key ARN for encryption at rest. Null uses the AWS-managed MSK key."
  default     = null
}

variable "encryption_in_transit_client_broker" {
  type        = string
  description = "Encryption between clients and brokers: TLS, TLS_PLAINTEXT or PLAINTEXT."
  default     = "TLS"

  validation {
    condition     = contains(["TLS", "TLS_PLAINTEXT", "PLAINTEXT"], var.encryption_in_transit_client_broker)
    error_message = "encryption_in_transit_client_broker must be one of TLS, TLS_PLAINTEXT, PLAINTEXT."
  }
}

variable "encryption_in_transit_in_cluster" {
  type        = bool
  description = "Whether data in transit between brokers is encrypted."
  default     = true
}

variable "enable_sasl_iam" {
  type        = bool
  description = "Enable SASL/IAM client authentication (broker port 9098). Requires TLS in transit."
  default     = false
}

variable "enable_sasl_scram" {
  type        = bool
  description = "Enable SASL/SCRAM client authentication (broker port 9096). Requires TLS in transit."
  default     = false
}

variable "enable_tls_auth" {
  type        = bool
  description = "Enable TLS mutual client authentication using ACM Private CAs."
  default     = false
}

variable "tls_certificate_authority_arns" {
  type        = list(string)
  description = "ACM Private CA ARNs used for TLS mutual authentication. Required when enable_tls_auth is true."
  default     = []
}

variable "enable_unauthenticated" {
  type        = bool
  description = "Allow unauthenticated access to the brokers."
  default     = false
}

variable "scram_secret_association_arns" {
  type        = list(string)
  description = "Secrets Manager secret ARNs to associate for SASL/SCRAM users. Used only when enable_sasl_scram is true."
  default     = []
}

variable "configuration_server_properties" {
  type        = string
  description = "Contents of an MSK configuration (server.properties). Empty disables the custom configuration."
  default     = ""
}

variable "log_group" {
  type        = string
  description = "CloudWatch log group name for broker logs. Empty disables CloudWatch logging."
  default     = ""
}

variable "logs_s3_bucket" {
  type        = string
  description = "S3 bucket for broker logs. Empty disables S3 logging."
  default     = ""
}

variable "logs_s3_prefix" {
  type        = string
  description = "Prefix for broker logs delivered to S3."
  default     = ""
}

variable "enable_open_monitoring" {
  type        = bool
  description = "Enable Prometheus open monitoring (JMX and node exporters)."
  default     = false
}

variable "open_monitoring_jmx_exporter" {
  type        = bool
  description = "Enable the JMX Prometheus exporter on brokers."
  default     = true
}

variable "open_monitoring_node_exporter" {
  type        = bool
  description = "Enable the node Prometheus exporter on brokers."
  default     = true
}

variable "enable_storage_autoscaling" {
  type        = bool
  description = "Automatically grow broker EBS storage with Application Auto Scaling."
  default     = false
}

variable "broker_storage_max_size" {
  type        = number
  description = "Maximum broker EBS volume size (GiB) autoscaling may grow to. Must be >= broker_volume_size. Used only when enable_storage_autoscaling is true."
  default     = 0
}

variable "broker_storage_target_utilization" {
  type        = number
  description = "Target storage-utilization percentage that triggers a scale-up. Used only when enable_storage_autoscaling is true."
  default     = 70
}
