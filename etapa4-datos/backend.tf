terraform {
  backend "s3" {
    bucket       = "tfstate-lab-541341196459-2023102598"
    key          = "etapa4/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
