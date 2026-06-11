
############################################
# 🔹 Storage Configuration
############################################

# Name of the libvirt storage pool to place VM disks in
variable "pool_name" {
  type        = string
  description = "Storage Pool Name"
  # default     = "default"
}
