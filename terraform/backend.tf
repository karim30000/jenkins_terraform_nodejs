terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket         = "myapp-bucket3000"
    key            = "myapp/state.tfstate"
    region         = "us-east-1"
    dynamodb_table = "test"
  }
}