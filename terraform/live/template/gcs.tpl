terraform {
  backend "gcs" {
    bucket  = "${env.gcs_bucket}"
    prefix     = "${path_key}
  }
}