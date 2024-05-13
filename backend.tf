terraform {
  backend "s3" {
    bucket  = "sebatyler-dev"
    key     = "terraform/state"
    region  = "ap-northeast-2"
    profile = "sebatyler"
  }
}
