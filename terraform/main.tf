terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

module "vcn" {
  source  = "oracle-terraform-modules/vcn/oci"
  version = "3.6.0"

  compartment_id = var.compartment_id
  region         = var.region
  
  vcn_name      = "${var.project_name}-vcn"
  vcn_dns_label = replace("${var.project_name}vcn", "-", "")
  vcn_cidrs     = ["10.0.0.0/16"]
  
  create_internet_gateway = true
  create_nat_gateway      = false
  create_service_gateway  = false
}

data "oci_core_subnets" "vcn_subnets" {
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id

  depends_on = [module.vcn]
}

module "compute" {
  source  = "oracle-terraform-modules/compute-instance/oci"
  version = "2.4.0"

  compartment_ocid      = var.compartment_id
  instance_count        = var.instance_count
  ad_number             = 1
  instance_display_name = "${var.project_name}-instance"
  
  source_type = "image"
  source_ocid = var.instance_image_id
  
  subnet_ocids = [data.oci_core_subnets.vcn_subnets.subnets[0].id]
  shape        = "VM.Standard.E2.1.Micro"
  
  ssh_public_keys = var.ssh_public_key

  depends_on = [module.vcn]
}
