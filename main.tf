terraform {
  backend "s3" {
  }
}

variable "project_id" {}
variable "region" {}
variable "zone" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "git_repo" {}
variable "ssh_public_key" {}
