
locals {
  # Load environment-specific variables from the env.hcl file in the same directory
  env          = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals

  # Determine cloud type from the path, assuming the structure is {live_path}/{cloud_type}/{env}/
  cloud_type   = split("/", path_relative_to_include())[0]

  # Backend type can be "local", "s3", or "gcs"
  backend_type = local.env.backend_type

  # Path to the live directory, used to determine cloud type and for generating backend configuration
  live_path    = local.env.live_path
  
}

remote_state {
  backend = local.backend_type

  config = local.backend_type == "local" ? {
    path = "terraform.tfstate"
    
  } : local.backend_type == "s3" ? {
    bucket  = local.env.s3_bucket
    key     = "${path_relative_to_include()}/terraform.tfstate"
    region  = local.env.s3_region
    encrypt = true
    
  } : local.backend_type == "gcs" ? {
    bucket  = local.env.gcs_bucket
    prefix  = "${path_relative_to_include()}/terraform.tfstate"
    project = local.env.project_id
    location = local.env.region
    
  } : {}

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents = templatefile(
    "${get_repo_root()}/${local.live_path}/${local.cloud_type}/templates/versions.tpl",
    {
    }
  )
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"

  contents = templatefile(
    "${get_repo_root()}/${local.live_path}/${local.cloud_type}/templates/provider.tpl",
    {
      env = local.env
    }
  )
}


