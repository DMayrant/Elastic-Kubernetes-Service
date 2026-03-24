terraform {
  backend "s3" {
    bucket         = "devops-tf-state-9711"
    key            = "eks/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-locks-simple"
    encrypt        = true
  }
}

