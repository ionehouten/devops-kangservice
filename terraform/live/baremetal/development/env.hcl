locals {

  # Backend Configuration can be "local", "s3", or "gcs"
  # Local backend configuration
  state_backend = "local"

  # S3 backend configuration
  # state_backend = "s3"
  # s3_bucket = "terraform-state-lab"
  # s3_region = "ap-southeast-3"

  # GCS backend configuration
  # state_backend = "gcs"
  # gcs_bucket = "terraform-state-lab"

  uri = "qemu:///system"
  # uri = "qemu+sshcmd://<USER>@<HOST>:<SSH_PORT>/system"
  pool_name = "default"
  network_name = "default"
  gateway = "192.168.122.1"
  dns = "8.8.8.8"
  ssh_public_key = "ssh-rsa xxxxx"
}

