# AWS provider and region
provider "aws" {
  region = "ap-southeast-1"
}

# prefix used to name the resources
locals {
  name_prefix = "faizal"
}