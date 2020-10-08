data "template_cloudinit_config" "this" {
  gzip          = true
  base64_encode = true

  # Main cloud-init config file
  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/files/cloud-config.yaml", {
      ssh_authorized_keys = var.ssh_authorized_keys
    })
  }

  part {
    filename     = "00_download.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/../common/download.sh", {
      # Must not use `version` here since that is reserved
      rke2_version = var.rke2_version
      type         = "server"
    })
  }

  part {
    filename     = "01_rke2.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/files/server.sh", {
      server_dns    = var.cluster_data.server_dns
      token_address = var.cluster_data.token.address

      config = var.rke2_config

      pre_userdata  = var.pre_userdata
      post_userdata = var.post_userdata
    })
  }
}
