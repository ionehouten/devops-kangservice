terraform {
  backend "s3" {
    bucket  = "${env.s3_bucket}"
    region  = "${env.s3_region}"
    key     = "${path_key}/terraform.tfstate"
    encrypt = true
    use_lockfile = ${lookup(env, "use_lockfile", true)}
  }
}