terraform {
  source = "../../../modules//lambda"
}
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "the-tfstate-bucket"

    key = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "my-lock-table"
  }
}
