resource "oci_core_network_security_group" "main" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.project}-${var.environment}-${var.name}"
  freeform_tags  = var.tags
}

resource "oci_core_network_security_group_security_rule" "instance_ingress" {
  for_each                  = var.nsg_ingress_rules
  network_security_group_id = oci_core_network_security_group.main.id
  direction                 = "INGRESS"
  protocol                  = each.value.protocol
  source                    = each.value.source
  source_type               = each.value.source_type
  description               = each.value.description
  dynamic "tcp_options" {
    for_each = each.value.protocol == "6" && each.value.port_min != null ? [1] : []
    content {
      destination_port_range {
        min = each.value.port_min
        max = each.value.port_max
      }
    }
  }

  dynamic "udp_options" {
    for_each = each.value.protocol == "17" && each.value.port_min != null ? [1] : []
    content {
      destination_port_range {
        min = each.value.port_min
        max = each.value.port_max
      }
    }
  }

}

resource "oci_core_network_security_group_security_rule" "instance_egress" {
  network_security_group_id = oci_core_network_security_group.main.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  description               = "Allow all outbound traffic"
}

resource "oci_core_instance" "main" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = "${var.project}-${var.environment}-${var.name}"
  shape               = var.shape
  freeform_tags       = var.tags


  create_vnic_details {
    assign_private_dns_record = true
    assign_public_ip          = var.assign_public_ip
    display_name              = "${var.project}-${var.environment}-${var.name}"
    nsg_ids                   = [oci_core_network_security_group.main.id]
    skip_source_dest_check    = var.skip_source_dest_check
    subnet_id                 = var.subnet_id
    freeform_tags             = var.tags
  }

  availability_config {
    is_live_migration_preferred = true
    recovery_action             = "RESTORE_INSTANCE"
  }

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }

  dynamic "licensing_configs" {
    for_each = var.licensing_configs_type != null ? [1] : []
    content {
      type         = var.licensing_configs_type
      license_type = var.licensing_configs_license_type
    }
  }

  source_details {
    source_id               = var.source_id
    source_type             = var.source_type
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
    kms_key_id              = var.kms_key_id
  }

  lifecycle {
    ignore_changes = [
      metadata,
      source_details[0].source_id
    ]
  }

  metadata = {
    ssh_authorized_keys = file("${path.root}/ssh_keys/${var.environment}/authorized_keys.pub")
  }

  preserve_boot_volume = false
}

data "oci_core_vnic_attachments" "main" {
  count          = var.create_reserved_public_ip ? 1 : 0
  compartment_id = var.compartment_id
  instance_id    = oci_core_instance.main.id
}

data "oci_core_private_ips" "main" {
  count   = var.create_reserved_public_ip ? 1 : 0
  vnic_id = data.oci_core_vnic_attachments.main[0].vnic_attachments[0].vnic_id
}

resource "oci_core_public_ip" "main" {
  count          = var.create_reserved_public_ip ? 1 : 0
  compartment_id = var.compartment_id
  lifetime       = "RESERVED"
  display_name   = "${var.project}-${var.environment}-${var.name}"
  private_ip_id  = data.oci_core_private_ips.main[0].private_ips[0].id
  freeform_tags  = var.tags
}
