variable "compartment_id" {
  type        = string
  description = "OCI Compartment ID"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to the SSH public key file"
}

variable "ubuntu_image_id" {
  type        = string
  description = "Ubuntu 22.04 image OCID"
  #   default     = "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaak2wd3czdm3x33xfj736bdamrty37xsce3pqeuzjimapepv3iiaeq"
  default = "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaa5tjkv5hnh5w24mikldsvlrg2njnypbbjbygmnvvvur2np5vemfsq"
}

variable "postgres_user" {
  type        = string
  description = "PostgreSQL user name"
  default     = "postgresuser"
}

variable "postgres_password" {
  type        = string
  description = "PostgreSQL password"
  sensitive   = true
}

variable "postgres_db" {
  type        = string
  description = "PostgreSQL database name"
  default     = "postgresdb"
}
