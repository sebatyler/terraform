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

resource "aws_route53_record" "postgres" {
  zone_id = data.aws_route53_zone.seba-kim.zone_id
  name    = "postgres.seba.kim"
  type    = "A"
  ttl     = 300
  records = [module.oracle_postgres.instance_public_ip]
}
