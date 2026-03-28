terraform {
  backend "s3" {
    bucket         = "diallo-terraform-state-xyz"
    key            = "day-4/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-lock"
  }
}

