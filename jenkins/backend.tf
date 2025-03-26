terraform {
  backend "s3" {
    bucket = "terraform-jenkins-eks-backend"
    key    = "jenkins/terraform.tfstate"
    region = "us-east-2"
  }
}