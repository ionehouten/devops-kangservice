
module "vms" {
  providers = {
    libvirt = libvirt
  }
  source = "../../../../../../../modules/baremetal/kvm-ubuntu-24.04"
  for_each = var.vms

  ubuntu_base_path  = var.ubuntu_base_path
  vm_name           = "vm-${each.value.hostname}"
  hostname          = each.value.hostname
  vcpu              = each.value.vcpu
  ram               = each.value.ram
  interfaces        = each.value.interfaces
  ip                = each.value.ip
  netmask           = var.netmask
  gateway           = var.gateway
  dns               = var.dns
  pool_name         = var.pool_name
  root_disk_size_gb = lookup(each.value, "root_disk_size_gb", 30)
  data_disks        = lookup(each.value, "disks", {})
  ssh_public_key    = var.ssh_public_key
}