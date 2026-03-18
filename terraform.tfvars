region                       = "eu-central-1"
project_name                 = "terraform-devsecops"
vpc_cidr                     = "10.0.0.0/16"

public_subnet_az1_cidr       = "10.0.10.0/24"
public_subnet_az2_cidr       = "10.0.20.0/24"

private_app_subnet_az1_cidr  = "10.0.30.0/24"
private_app_subnet_az2_cidr  = "10.0.40.0/24"
private_data_subnet_az1_cidr = "10.0.50.0/24"
private_data_subnet_az2_cidr = "10.0.60.0/24"

zones                        = ["eu-central-1a", "eu-central-1b"]
private_subnets              = ["10.0.30.0/24", "10.0.40.0/24", "10.0.50.0/24", "10.0.60.0/24"]
public_subnets               = ["10.0.10.0/24", "10.0.20.0/24"]