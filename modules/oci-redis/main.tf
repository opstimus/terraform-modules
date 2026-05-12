resource "oci_core_network_security_group" "main" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.project}-${var.environment}-${var.name}"
  freeform_tags  = var.tags
}

resource "oci_core_network_security_group_security_rule" "redis_ingress" {
  for_each = toset(var.allowed_cidrs)

  network_security_group_id = oci_core_network_security_group.main.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = each.value
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 6379
      max = 6379
    }
  }
}

resource "oci_core_network_security_group_security_rule" "redis_egress" {
  network_security_group_id = oci_core_network_security_group.main.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 1024
      max = 65535
    }
  }
}

resource "oci_redis_oci_cache_config_set" "main" {
  compartment_id = var.compartment_id
  configuration_details {
    #Required
    items {
      #Required
      config_key   = var.config_key
      config_value = var.config_value
    }
  }
  display_name     = "${var.project}-${var.environment}-${var.name}-redis-cache-config-set"
  software_version = var.software_version
  freeform_tags    = var.tags
}

resource "oci_redis_redis_cluster" "main" {
  compartment_id          = var.compartment_id
  display_name            = "${var.project}-${var.environment}-${var.name}-redis-cluster"
  node_count              = var.node_count
  node_memory_in_gbs      = var.node_memory_in_gbs
  software_version        = var.software_version
  subnet_id               = var.subnet_id
  cluster_mode            = var.cluster_mode
  nsg_ids                 = [oci_core_network_security_group.main.id]
  oci_cache_config_set_id = oci_redis_oci_cache_config_set.main.id
  shard_count             = var.cluster_mode == "SHARDED" ? var.shard_count : null
  freeform_tags           = var.tags
}
