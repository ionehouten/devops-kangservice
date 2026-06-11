include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "../../../../modules/baremetal/image-base"
}

inputs = {
  pool_name = local.env.locals.pool_name
}
