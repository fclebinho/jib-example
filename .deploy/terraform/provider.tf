terraform {
  backend "s3" {
    bucket = "jib-terraform-state-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
}
