locals {
  is_custom_domain  = var.custom_domain != "" && var.managed_zone_name != ""
  custom_domain_ext = (var.skip_domain_workspace_alignment || terraform.workspace == "default") ? "" : terraform.workspace
  custom_domain     = "${local.custom_domain_ext == "" ? "" : "${local.custom_domain_ext}-"}${var.custom_domain}"
  ingress_domain    = local.is_custom_domain ? local.custom_domain : "${google_compute_instance.acebox.network_interface.0.access_config.0.nat_ip}.nip.io"
  fw_target_tag     = "${var.name_prefix}-${random_id.uuid.hex}"
}

resource "random_id" "uuid" {
  byte_length = 4
}

resource "google_compute_address" "acebox" {
  name = "${var.name_prefix}-ipv4-addr-${random_id.uuid.hex}"
}

resource "google_compute_firewall" "acebox_http" {
  name    = "${var.name_prefix}-allow-http-${random_id.uuid.hex}"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags   = [local.fw_target_tag]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "acebox_https" {
  name    = "${var.name_prefix}-allow-https-${random_id.uuid.hex}"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["443", "16443"]
  }

  target_tags   = [local.fw_target_tag]
  source_ranges = ["0.0.0.0/0"]
}

module "ssh_key" {
  source = "../modules/ssh"
}

resource "google_compute_instance" "acebox" {
  name         = "${var.name_prefix}-${random_id.uuid.hex}"
  machine_type = var.acebox_size
  zone         = var.gcloud_zone

  boot_disk {
    initialize_params {
      image = var.acebox_os
      size  = var.disk_size
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.acebox.address
    }
  }

  metadata = {
    sshKeys = "${var.acebox_user}:${module.ssh_key.public_key_openssh}"
  }

  tags = [local.fw_target_tag]
}

#
# Dashboard Password
#
locals {
  generate_random_password = var.dashboard_password == ""
  dashboard_password       = coalescelist(random_password.dashboard_password[*].result, [var.dashboard_password])[0]
}

resource "random_password" "dashboard_password" {
  count  = local.generate_random_password ? 1 : 0
  length = 12
}

#
# Provisioner
#
module "provisioner" {
  source = "../modules/ace-box-provisioner"

  host               = google_compute_instance.acebox.network_interface.0.access_config.0.nat_ip
  user               = var.acebox_user
  private_key        = module.ssh_key.private_key_pem
  ingress_domain     = local.ingress_domain
  ingress_protocol   = var.ingress_protocol
  dt_tenant          = var.dt_tenant
  dt_api_token       = var.dt_api_token
  use_case           = var.use_case
  extra_vars         = var.extra_vars
  dashboard_user     = var.dashboard_user
  dashboard_password = local.dashboard_password
  ace_box_version    = var.ace_box_version
}
