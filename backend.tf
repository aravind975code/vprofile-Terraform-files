terraform {
  backend "s3" {
    bucket = "975aravind"
    key    = "terraform/backend"
    region = "us-east-1"
  }
}
