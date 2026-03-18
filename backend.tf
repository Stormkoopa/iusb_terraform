terraform { 
	backend "s3" {  
		bucket = "sbiu-terraform-state" 
		key = "terraform.tfstate"
		region = "eu-central-1"
		encrypt = true
        use_lockfile = true
	}
}