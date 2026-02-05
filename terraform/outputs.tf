output "vcn_id" {
  description = "OCID da VCN criada"
  value       = module.vcn.vcn_id
}

output "subnet_id" {
  description = "OCID da subnet pública"
  value       = oci_core_subnet.public.id
}

output "instance_ids" {
  description = "OCIDs das instâncias criadas"
  value       = module.compute.instance_id
}

output "instance_public_ips" {
  description = "IPs públicos das instâncias"
  value       = module.compute.public_ip
}
