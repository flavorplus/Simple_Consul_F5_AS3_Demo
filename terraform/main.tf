terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_region
}

provider "random" {
  version = "3.0.0"
}

resource "random_pet" "name" {
  length = 2
  prefix = "F5_Consul_Demo"
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    owner           = var.owner
    created-by      = var.created-by
    sleep-at-night  = var.sleep-at-night
    TTL             = var.TTL
  }
}

data "aws_ami" "base" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

