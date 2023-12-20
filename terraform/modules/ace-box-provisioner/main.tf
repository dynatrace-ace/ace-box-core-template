locals {
  host               = var.host
  type               = "ssh"
  user               = var.user
  private_key        = var.private_key
  user_skel_path     = "${path.module}/../../../user-skel/"
  ingress_domain     = var.ingress_domain
  ingress_protocol   = var.ingress_protocol
  dt_tenant          = var.dt_tenant
  dt_api_token       = var.dt_api_token
  host_group         = var.host_group
  extra_vars         = var.extra_vars
  dashboard_user     = var.dashboard_user
  dashboard_password = var.dashboard_password
}

resource "null_resource" "provisioner_init" {
  connection {
    host        = local.host
    type        = local.type
    user        = local.user
    private_key = local.private_key
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait || echo \"Skipping cloud-init wait...\"",
      "curl -sfL https://storage.googleapis.com/ace-box-public-roles/${var.ace_box_version}/init.sh | sudo ACE_BOX_USER=${local.user} sh -"
    ]
  }
}

locals {
  prepare_cmd = [
    "sudo",
    # "ACE_ANSIBLE_WORKDIR=/home/${local.user}/ansible/",
    "ACE_BOX_USER=${local.user}",
    "ACE_INGRESS_DOMAIN=${local.ingress_domain}",
    "ACE_INGRESS_PROTOCOL=${local.ingress_protocol}",
    "ACE_DT_TENANT=${local.dt_tenant}",
    "ACE_DT_API_TOKEN=${local.dt_api_token}",
    "ACE_HOST_GROUP=${local.host_group}",
    "ACE_DASHBOARD_USER=${local.dashboard_user}",
    # "ACE_DASHBOARD_PASSWORD=\"${local.dashboard_password}\"",
    "ACE_DASHBOARD_PASSWORD=\"supersecret\"",
    "ace prepare --force"
  ]
  ace_extra_vars = [
    for k, v in var.extra_vars : "--extra-var=${k}=${v}"
  ]
}

resource "null_resource" "provisioner_ace_prepare" {
  triggers = {
    host        = local.host
    type        = local.type
    user        = local.user
    private_key = local.private_key
    prepare_cmd = trimspace(join(" ", local.prepare_cmd))
    extra_vars  = trimspace(join(" ", local.ace_extra_vars))
  }

  connection {
    host        = self.triggers.host
    type        = self.triggers.type
    user        = self.triggers.user
    private_key = self.triggers.private_key
  }

  depends_on = [null_resource.provisioner_init]

  provisioner "remote-exec" {
    inline = [
      trimspace(join(" ", [self.triggers.prepare_cmd, self.triggers.extra_vars]))
    ]
  }
}
