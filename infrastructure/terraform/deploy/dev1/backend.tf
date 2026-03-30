terraform {
  backend "s3" {
    bucket = "k8s-platform-tf-state-975049983446"
    key    = "deploy/dev/dev-01/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "k8s-platform-tf-locks"
  }
}