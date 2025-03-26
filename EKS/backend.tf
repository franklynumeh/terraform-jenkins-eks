terraform {
  backend "s3" {
    bucket = "terraform-jenkins-eks-backend"
    key    = "eks/terraform.tfstate"
    region = "us-east-2"
  }
}