terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    oci = {
      source  = "oracle/oci"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-2"
  profile = "sebatyler"
}

provider "oci" {
  config_file_profile = "DEFAULT"
}

module "oracle_postgres" {
  source = "./modules/oracle-postgres"

  compartment_id      = var.compartment_id
  ssh_public_key_path = var.ssh_public_key_path

  postgres_user     = var.postgres_user
  postgres_password = var.postgres_password
  postgres_db       = var.postgres_db
}
