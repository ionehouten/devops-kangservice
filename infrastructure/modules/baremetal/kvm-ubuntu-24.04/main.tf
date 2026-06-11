
terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.9.0"
    }
  }
}

locals {
  cloudinit_userdata = templatefile(
    "${path.module}/cloudinit-userdata.yaml",
    {
      hostname = var.hostname
      ip       = var.ip
      netmask  = var.netmask
      gateway  = var.gateway
      dns      = var.dns
      ssh_key  = var.ssh_public_key
    }
  )
}

locals {
  cloudinit_metadata = templatefile(
    "${path.module}/cloudinit-metadata.yaml",
    {
      vm_name  = var.vm_name
      hostname = var.hostname
    }
  )
}

locals {
  data_disk_letters = ["b", "c", "d", "e", "f"]
}



resource "libvirt_cloudinit_disk" "cloudinit" {
  name      = "${var.vm_name}-cloudinit.iso"
  user_data = local.cloudinit_userdata
  meta_data = local.cloudinit_metadata

  lifecycle {
    ignore_changes = all
  }
}

resource "libvirt_volume" "cloudinit" {
  name = libvirt_cloudinit_disk.cloudinit.name
  pool = var.pool_name

  create = {
    content = {
      url = libvirt_cloudinit_disk.cloudinit.path
    }
  }

  lifecycle {
    ignore_changes = [
      create,
    ]
  }
}



resource "libvirt_volume" "root_disk" {
  name     = "${var.vm_name}-root.qcow2"
  pool     = var.pool_name
  format   = "qcow2"
  capacity = var.root_disk_size_gb * 1024 * 1024 * 1024
  backing_store = {
    path   = var.ubuntu_base_path
    format = "qcow2"
  }
}


resource "libvirt_volume" "data_disks" {
  for_each = var.data_disks
  name     = "${var.vm_name}-${each.key}.qcow2"
  pool     = var.pool_name
  format   = "qcow2"
  capacity = each.value.size_gb * 1024 * 1024 * 1024
}



resource "libvirt_domain" "vm" {
  name   = var.vm_name
  vcpu   = var.vcpu
  memory = var.ram * 1024
  type   = "kvm"

  # Start the VM automatically when host reboot
  autostart = true
  # Start the VM automatically when created
  running = true


  cpu = {
    mode = "host-passthrough"
    # topology {
    #   sockets = 1
    #   cores   = 4
    #   threads = 1
    # }
  }

  # Boot configuration
  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"
  }


  devices = {
    disks = concat(
      [
        {
          source = {
            pool   = libvirt_volume.root_disk.pool
            volume = libvirt_volume.root_disk.name
          }
          target = {
            bus = "virtio"
            dev = "vda"
          }
        },
      ],
      [
        for idx, v in values(libvirt_volume.data_disks) :
        {
          source = {
            pool   = v.pool
            volume = v.name
          }
          target = {
            bus = "virtio"
            dev = "vd${local.data_disk_letters[idx]}"
          }
        }
      ],
      [
        {
          device = "cdrom"
          source = {
            pool   = libvirt_volume.cloudinit.pool
            volume = libvirt_volume.cloudinit.name
          }
          target = {
            bus = "sata"
            dev = "sda"
          }
        }
      ]
    )

    

    interfaces = [
      for iface in var.interfaces : {
        type  = iface.type
        model = iface.model
        source = {
          bridge  = try(iface.source.bridge, null)
          network = try(iface.source.network, null)
        }
      }
    ]

    graphics = {
      vnc = {
        autoport = "yes"
        listen   = "127.0.0.1"
      }
    }
  }

}
