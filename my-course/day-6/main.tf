module "ec2_instance" {
  source = "./modules/ec2_instance"
  
  region        = var.region
  ami_value     = var.ami_value
  instance_type = terraform.workspace == "prod" ? var.prod_instance_type : var.dev_instance_type
  ec2_tag_name  = lookup(var.ec2_tag_name, terraform.workspace)
}

// terraform apply -var-file="vars_dev.tfvars"
// terraform show

// terraform workspace list
// terraform workspace new prod
// terraform workspace show
// terraform workspace select prod
// terraform apply -var-file="vars_prod.tfvars"