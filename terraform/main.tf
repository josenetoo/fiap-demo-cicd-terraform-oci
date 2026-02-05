terraform {
  required_version = ">= 1.9.0"
  
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

# Data source para obter availability domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

# Módulo VCN com subnet
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

# Criar subnet manualmente usando outputs do módulo VCN
resource "oci_core_subnet" "public" {
  compartment_id    = var.compartment_id
  vcn_id            = module.vcn.vcn_id
  cidr_block        = "10.0.1.0/24"
  display_name      = "${var.project_name}-public-subnet"
  dns_label         = "public"
  route_table_id    = module.vcn.ig_route_id
  security_list_ids = [module.vcn.vcn_all_attributes.default_security_list_id]
  
  prohibit_public_ip_on_vnic = false
}

# Atualizar security list padrão para permitir SSH e HTTP
resource "oci_core_default_security_list" "default" {
  manage_default_resource_id = module.vcn.vcn_all_attributes.default_security_list_id
  
  display_name = "${var.project_name}-default-sl"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }
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
  
  subnet_ocids    = [oci_core_subnet.public.id]
  shape           = "VM.Standard.E2.1.Micro"
  ssh_public_keys = var.ssh_public_key
  
  assign_public_ip = true
}
