terraform {
  backend "s3" {
    bucket       = "nexuscore-terraform-state-1111"
    key          = "portfolio/multitier/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}