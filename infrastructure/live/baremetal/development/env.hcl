locals {
  # Live path is the base directory for all live environments, used to determine cloud type and for generating backend configuration
  live_path = "infrastructure/live"

  # Backend Configuration can be "local", "s3", or "gcs"

  # Local backend configuration
  backend_type = "local"

  # S3 backend configuration
  # backend_type = "s3"
  # s3_bucket = "terraform-state-lab"
  # s3_region = "ap-southeast-3"

  # GCS backend configuration
  # backend_type = "gcs"
  # gcs_bucket = "terraform-state-lab"

  uri = "qemu:///system"
  # uri = "qemu+sshcmd://<USER>@<HOST>:<SSH_PORT>/system"
  pool_name      = "default"
  network_name   = "default"
  gateway        = "192.168.122.1"
  dns            = "8.8.8.8"
  ssh_public_key = "ssh-rsa xxxxx"
  
}

