############################################
# 🔹 VM Identity
############################################
# BasePath Ubuntu Image
variable "ubuntu_base_path" {
  type = string
}

# Name of the virtual machine in libvirt
variable "vm_name" {
  type = string
}

# Hostname configured inside the guest OS (cloud-init)
variable "hostname" {
  type = string
}


############################################
# 🔹 CPU & Memory Resources
############################################

# Number of virtual CPUs assigned to the VM
variable "vcpu" {
  type = number
}

# Amount of RAM in GB (2)
variable "ram" {
  type = number
}


############################################
# 🔹 Networking Configuration
############################################

# Network connection type:
# - bridge name (e.g., "br-vmhausapp") for direct L2 access
# - libvirt network name (e.g., "default") for NAT mode
# variable "bridge" {
#   type = string
# }


variable "interfaces" {
  description = "List Network Interfaces"
  type = list(object({
    type   = string
    model  = string
    
    source = optional(object({
      bridge       = optional(string)
      network = optional(string)
    }))
  }))

  default = [
    {
      type  = "network"
      model = "virtio"
      source = {
        bridge = null
        network = null
      }
    }
  ]
}

# Static IP address of the VM
variable "ip" {
  type = string
}

# Netmask in CIDR numeric form (example: 24 means 255.255.255.0)
variable "netmask" {
  type = number
}

# Default gateway for the VM
variable "gateway" {
  type = string
}

# DNS server address (single value)
variable "dns" {
  type = string
}


############################################
# 🔹 Storage Configuration
############################################

# Name of the libvirt storage pool to place VM disks in
variable "pool_name" {
  type        = string
  description = "Storage Pool Name"
  default     = "default"
}

# Size of the root OS disk in gigabytes
variable "root_disk_size_gb" {
  type    = number
  default = 30
}

# Optional additional data disks
# Example usage:
# data_disks = {
#   data1 = { size_gb = 50 }
#   data2 = { size_gb = 100 }
# }
variable "data_disks" {
  type = map(object({
    size_gb = number
  }))
  default = {}
}


############################################
# 🔹 Access Configuration
############################################

# SSH public key to be injected into the VM using cloud-init
variable "ssh_public_key" {
  type = string
}
