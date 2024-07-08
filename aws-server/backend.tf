terraform {
  backend "s3" {
    bucket   = "terraform-remote-state-2024"
    key      = "aws-server/terraform.tfstate"
    region   = "us-east-1"
    profile  = "default"
  }
}