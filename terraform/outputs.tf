output "vcn_id" {
  description = "OCID da VCN criada"
  value       = module.vcn.vcn_id
}

output "subnet_ids" {
  description = "OCIDs das subnets criadas"
  value       = module.vcn.subnet_ids
}

output "instance_ids" {
  description = "OCIDs das instâncias criadas"
  value       = module.compute.instance_id
}

output "instance_public_ips" {
  description = "IPs públicos das instâncias"
  value       = module.compute.public_ip
}
