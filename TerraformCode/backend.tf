terraform {
  backend "s3" {
    region = "us-west-2"
    key    = "state_file.tfstate"
    bucket = "your-bucket-name"
  }
}