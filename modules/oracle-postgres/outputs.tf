output "instance_public_ip" {
  value = oci_core_instance.postgres_instance.public_ip
}

output "instance_id" {
  value = oci_core_instance.postgres_instance.id
}

output "postgres_connection_string" {
  value     = "postgresql://postgresuser:your_secure_password@${oci_core_instance.postgres_instance.public_ip}:5432/postgresdb"
  sensitive = true
}
