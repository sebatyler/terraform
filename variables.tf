variable "compartment_id" {
  type        = string
  description = "OCI Compartment ID"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to the SSH public key file"
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

variable "github_pages_domain_verification_token" {
  type        = string
  description = "GitHub Pages domain verification token"
}
