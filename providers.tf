provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# todo:
#  - launch template that clones a git repository upon spot creation
#  - spot request
