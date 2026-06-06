####################################################################################
## Global Variables
####################################################################################

variable "ubuntu_base_path" {
  type        = string
  description = "The absolute path to the pre-downloaded Ubuntu base qcow2 image file."
}

variable "ssh_public_key" {
  type        = string
  description = "The SSH Public Key to be injected into cloud-init for all created VMs."
}

variable "pool_name" {
  type        = string
  default     = "default"
  description = "The name of the KVM/Libvirt storage pool where the VM disks will be allocated."
}

variable "netmask" {
  type        = number
  default     = 24
  description = "The subnet mask in CIDR format (e.g., 24 for 255.255.255.0)."
}

variable "gateway" {
  type        = string
  default     = "10.10.200.1"
  description = "The primary default gateway IP address for the VM network interface."
}

variable "dns" {
  type        = string
  default     = "8.8.8.8"
  description = "The DNS Server IP address to be assigned to the VMs."
}

####################################################################################
## Core Loop Variable (Map structure schema for for_each)
####################################################################################

variable "vms" {
  type = map(object({
    hostname          = string
    ip                = string
    vcpu              = number
    ram               = number
    root_disk_size_gb = optional(number, 30) # Leverages Terraform's optional attribute feature
    
    # Defines the array of network interfaces (bridge, network, or NAT)
    interfaces = list(object({
      type   = string
      model  = optional(string, "virtio")
      source = map(any)
    }))

    # Defines additional secondary data disks if required
    disks = optional(map(object({
      size_gb = number
    })), {})
  }))
  description = "A comprehensive map containing the specific resource configurations for each individual VM."
}

