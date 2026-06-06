####################################################################################
## Terraform
####################################################################################

resource "null_resource" "download_ubuntu24" {
  provisioner "local-exec" {
    command = <<EOT
      mkdir -p /kvm/cloud-images
      if [ ! -f /kvm/cloud-images/ubuntu-24.04-cloudimg-amd64.img ]; then
        wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img \
          -O /kvm/cloud-images/ubuntu-24.04-cloudimg-amd64.img
      fi
    EOT
  }
}

resource "libvirt_volume" "ubuntu24_base" {
  depends_on = [null_resource.download_ubuntu24]

  name   = "ubuntu24-base.qcow2"
  pool   = var.pool_name
  format = "qcow2"
  create = {
    content = {
      url = "/kvm/cloud-images/ubuntu-24.04-cloudimg-amd64.img"
    }
  }

  # lifecycle {
  #   prevent_destroy = true
  # }
}
