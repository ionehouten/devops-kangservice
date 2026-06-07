
locals {
  env          = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  backend_type = local.env.locals.state_backend
  cloud_type   = split("/", path_relative_to_include())[0]
}

# remote_state {
#   backend = "local"

#   config = {
#     path = "${get_terragrunt_dir()}/terraform.tfstate"
#   }
# }

generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents = templatefile(
    "${get_repo_root()}/terraform/live/template/versions.tpl",
    {
    }
  )
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"

  contents = templatefile(
    "${get_repo_root()}/terraform/live/${local.cloud_type}/templates/provider.tpl",
    {
      env = local.env.locals
    }
  )
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"

  contents = templatefile(
    "${get_repo_root()}/terraform/live/template/${local.env.locals.state_backend}.tpl",
    {
      terragrunt_dir = get_terragrunt_dir()
      path_key       = path_relative_to_include()
      env            = local.env.locals
    }
  )
}

