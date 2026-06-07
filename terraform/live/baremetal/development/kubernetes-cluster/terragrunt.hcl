include "root" {
  path = find_in_parent_folders("root.hcl")
}


locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependency "image_base" {
  config_path = "../image-base"
  mock_outputs = {
    ubuntu_base_path   = "/kvm/storage/ubuntu24-base.qcow2"
  }
}


terraform {
  source = "../../../../modules/baremetal/libvirt-vms"
}

inputs = {

  ubuntu_base_path = dependency.image_base.outputs.ubuntu_base_path
  pool_name = local.env.locals.pool_name
  gateway = local.env.locals.gateway
  dns = local.env.locals.dns
  ssh_public_key = local.env.locals.ssh_public_key

  vms = {

    k8s-master-01 = {
      hostname          = "k8s-master-01"
      ip                = "192.168.122.10"
      vcpu              = 2
      ram               = 16384
      root_disk_size_gb = 30
      disks = {
        # data_1 = { size_gb = 100 }
      }

      # NAT
      interfaces = [
        {
          type  = "network"
          model = "virtio"
          source = {
            network = local.env.locals.network_name
          }
        }
      ]

      # Bridge example
      # interfaces = [
      #   {
      #     type  = "bridge"
      #     model = "virtio"
      #     source = {
      #       bridge = local.env.locals.network_name
      #     }
      #   }
      # ]
    }

    k8s-worker-01 = {
      hostname          = "k8s-worker-01"
      ip                = "192.168.122.11"
      vcpu              = 4
      ram               = 25600
      root_disk_size_gb = 40
      disks = {
        # data_1 = { size_gb = 100 }
      }

      interfaces = [
        {
          type  = "network"
          model = "virtio"
          source = {
            network = local.env.locals.network_name
          }
        }
      ]
    }

    k8s-worker-02 = {
      hostname          = "k8s-worker-02"
      ip                = "192.168.122.12"
      vcpu              = 4
      ram               = 25600
      root_disk_size_gb = 40
      disks = {
        # data_1 = { size_gb = 100 }
      }
      interfaces = [
        {
          type  = "network"
          model = "virtio"
          source = {
            network = local.env.locals.network_name
          }
        }
      ]
    }

    k8s-worker-03 = {
      hostname          = "k8s-worker-03"
      ip                = "192.168.122.13"
      vcpu              = 4
      ram               = 25600
      root_disk_size_gb = 40
      disks = {
        # data_1 = { size_gb = 100 }
      }
      interfaces = [
        {
          type  = "network"
          model = "virtio"
          source = {
            network = local.env.locals.network_name
          }
        }
      ]
    }

    k8s-workerdb-01 = {
      hostname          = "k8s-workerdb-01"
      ip                = "192.168.122.14"
      vcpu              = 8
      ram               = 32768
      root_disk_size_gb = 50
      disks = {
        data_1 = { size_gb = 150 }
      }
      interfaces = [
        {
          type  = "network"
          model = "virtio"
          source = {
            network = local.env.locals.network_name
          }
        }
      ]
    }


  }
}

