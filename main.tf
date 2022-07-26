terraform {
  backend "s3" {
  }
}

variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

variable "zone" {
  description = "zone"
}

variable "aws_access_key" {}
variable "aws_secret_key" {}
