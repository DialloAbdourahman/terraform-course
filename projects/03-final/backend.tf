terraform {
  backend "s3" {
    bucket               = "diallo-abdourahman-terraform-state-xyz"
    key                  = "terraform.tfstate"
    workspace_key_prefix = "final-course-project"
    region               = "eu-north-1"
    dynamodb_table       = "terraform-lock"
  }
}
