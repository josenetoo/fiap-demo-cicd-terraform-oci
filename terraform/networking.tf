# # -----------------------------------------------------
# # VCN (Virtual Cloud Network) - Dedicada para OKE
# # -----------------------------------------------------
# # Nota: data.oci_identity_availability_domains.ads está definido no main.tf
# resource "oci_core_vcn" "oke" {
#   compartment_id = var.compartment_id
#   display_name   = "${var.project_name}-oke-vcn"
#   cidr_blocks    = [var.oke_vcn_cidr]
#   dns_label      = "${replace(var.project_name, "-", "")}oke"

#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#     "Purpose"     = "OKE"
#     "ManagedBy"   = "Terraform"
#   }
# }

# # -----------------------------------------------------
# # Internet Gateway - Acesso público à internet
# # -----------------------------------------------------
# resource "oci_core_internet_gateway" "oke" {
#   compartment_id = var.compartment_id
#   vcn_id         = oci_core_vcn.oke.id
#   display_name   = "${var.project_name}-oke-igw"
#   enabled        = true

#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#   }
# }

# # -----------------------------------------------------
# # NAT Gateway - Acesso à internet para subnets privadas
# # -----------------------------------------------------
# resource "oci_core_nat_gateway" "oke" {
#   compartment_id = var.compartment_id
#   vcn_id         = oci_core_vcn.oke.id
#   display_name   = "${var.project_name}-oke-nat"

#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#   }
# }

# # -----------------------------------------------------
# # Service Gateway - Acesso aos serviços OCI (OCIR, Object Storage)
# # -----------------------------------------------------
# data "oci_core_services" "all_services" {
#   filter {
#     name   = "name"
#     values = ["All .* Services In Oracle Services Network"]
#     regex  = true
#   }
# }

# resource "oci_core_service_gateway" "oke" {
#   compartment_id = var.compartment_id
#   vcn_id         = oci_core_vcn.oke.id
#   display_name   = "${var.project_name}-oke-sgw"

#   services {
#     service_id = data.oci_core_services.all_services.services[0].id
#   }

#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#   }
# }

# # -----------------------------------------------------
# # Route Table - Pública (via Internet Gateway)
# # -----------------------------------------------------
# resource "oci_core_route_table" "oke_public" {
#   compartment_id = var.compartment_id
#   vcn_id         = oci_core_vcn.oke.id
#   display_name   = "${var.project_name}-oke-rt-public"

#   route_rules {
#     destination       = "0.0.0.0/0"
#     destination_type  = "CIDR_BLOCK"
#     network_entity_id = oci_core_internet_gateway.oke.id
#   }

#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#   }
# }

# # -----------------------------------------------------
# # Route Table - Privada (via NAT Gateway + Service Gateway)
# # -----------------------------------------------------
# resource "oci_core_route_table" "oke_private" {
#   compartment_id = var.compartment_id
#   vcn_id         = oci_core_vcn.oke.id
#   display_name   = "${var.project_name}-oke-rt-private"

#   route_rules {
#     destination       = "0.0.0.0/0"
#     destination_type  = "CIDR_BLOCK"
#     network_entity_id = oci_core_nat_gateway.oke.id
#   }

#   route_rules {
#     destination       = data.oci_core_services.all_services.services[0].cidr_block
#     destination_type  = "SERVICE_CIDR_BLOCK"
#     network_entity_id = oci_core_service_gateway.oke.id
#   }

#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#   }
# }

# # -----------------------------------------------------
# # Security List - API Endpoint (Kubernetes API)
# # -----------------------------------------------------
# resource "oci_core_security_list" "oke_api" {
#   compartment_id = var.compartment_id
#   vcn_id         = oci_core_vcn.oke.id
#   display_name   = "${var.project_name}-oke-sl-api"

#   egress_security_rules {
#     destination = "0.0.0.0/0"
#     protocol    = "all"
#   }

#   # Kubernetes API
#   ingress_security_rules {
#     protocol = "6"
#     source   = "0.0.0.0/0"
#     tcp_options {
#       min = 6443
#       max = 6443
#     }
#   }

#   # OKE Control Plane (node bootstrap)
#   ingress_security_rules {
#     protocol = "6"
#     source   = var.oke_vcn_cidr
#     tcp_options {
#       min = 12250
#       max = 12250
#     }
#   }

#   # ICMP
#   ingress_security_rules {
#     protocol = "1"
#     source   = var.oke_vcn_cidr
#   }

#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#     "Subnet"      = "api-endpoint"
#   }
# }

# # -----------------------------------------------------
# # Security List - Workers (OKE Nodes)
# # -----------------------------------------------------
# resource "oci_core_security_list" "oke_workers" {
#   compartment_id = var.compartment_id
#   vcn_id         = oci_core_vcn.oke.id
#   display_name   = "${var.project_name}-oke-sl-workers"

#   egress_security_rules {
#     destination = "0.0.0.0/0"
#     protocol    = "all"
#   }

#   # Todo tráfego interno da VCN
#   ingress_security_rules {
#     protocol = "all"
#     source   = var.oke_vcn_cidr
#   }

#   # SSH (opcional, para debug)
#   ingress_security_rules {
#     protocol = "6"
#     source   = "0.0.0.0/0"
#     tcp_options {
#       min = 22
#       max = 22
#     }
#   }

#   # Kubelet API
#   ingress_security_rules {
#     protocol = "6"
#     source   = var.oke_vcn_cidr
#     tcp_options {
#       min = 10250
#       max = 10250
#     }
#   }

#   # NodePort range
#   ingress_security_rules {
#     protocol = "6"
#     source   = "0.0.0.0/0"
#     tcp_options {
#       min = 30000
#       max = 32767
#     }
#   }

#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#     "Subnet"      = "workers"
#   }
# }

# # -----------------------------------------------------
# # Security List - Load Balancer
# # -----------------------------------------------------
# resource "oci_core_security_list" "oke_lb" {
#   compartment_id = var.compartment_id
#   vcn_id         = oci_core_vcn.oke.id
#   display_name   = "${var.project_name}-oke-sl-lb"

#   egress_security_rules {
#     destination = "0.0.0.0/0"
#     protocol    = "all"
#   }

#   # HTTP
#   ingress_security_rules {
#     protocol = "6"
#     source   = "0.0.0.0/0"
#     tcp_options {
#       min = 80
#       max = 80
#     }
#   }

#   # HTTPS
#   ingress_security_rules {
#     protocol = "6"
#     source   = "0.0.0.0/0"
#     tcp_options {
#       min = 443
#       max = 443
#     }
#   }

#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#     "Subnet"      = "load-balancer"
#   }
# }

# # -----------------------------------------------------
# # Security List - Pods (VCN Native Pod Networking)
# # -----------------------------------------------------
# resource "oci_core_security_list" "oke_pods" {
#   compartment_id = var.compartment_id
#   vcn_id         = oci_core_vcn.oke.id
#   display_name   = "${var.project_name}-oke-sl-pods"

#   egress_security_rules {
#     destination = "0.0.0.0/0"
#     protocol    = "all"
#   }

#   # Todo tráfego interno da VCN (pod-to-pod, pod-to-service)
#   ingress_security_rules {
#     protocol = "all"
#     source   = var.oke_vcn_cidr
#   }

#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#     "Subnet"      = "pods"
#   }
# }

# # -----------------------------------------------------
# # Subnet - API Endpoint (pública ou privada)
# # -----------------------------------------------------
# resource "oci_core_subnet" "oke_api" {
#   compartment_id             = var.compartment_id
#   vcn_id                     = oci_core_vcn.oke.id
#   display_name               = "${var.project_name}-oke-subnet-api"
#   cidr_block                 = var.oke_subnet_api_cidr
#   route_table_id             = oci_core_route_table.oke_public.id
#   security_list_ids          = [oci_core_security_list.oke_api.id]
#   dns_label                  = "okeapi"
#   prohibit_public_ip_on_vnic = false # API endpoint público

#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#     "Purpose"     = "OKE-API-Endpoint"
#   }
# }

# # -----------------------------------------------------
# # Subnet - Worker Nodes (privada)
# # -----------------------------------------------------
# resource "oci_core_subnet" "oke_workers" {
#   compartment_id             = var.compartment_id
#   vcn_id                     = oci_core_vcn.oke.id
#   display_name               = "${var.project_name}-oke-subnet-workers"
#   cidr_block                 = var.oke_subnet_workers_cidr
#   route_table_id             = oci_core_route_table.oke_private.id
#   security_list_ids          = [oci_core_security_list.oke_workers.id]
#   dns_label                  = "okeworkers"
#   prohibit_public_ip_on_vnic = true # Workers em subnet privada

#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#     "Purpose"     = "OKE-Workers"
#   }
# }

# # -----------------------------------------------------
# # Subnet - Load Balancer (pública)
# # -----------------------------------------------------
# resource "oci_core_subnet" "oke_lb" {
#   compartment_id             = var.compartment_id
#   vcn_id                     = oci_core_vcn.oke.id
#   display_name               = "${var.project_name}-oke-subnet-lb"
#   cidr_block                 = var.oke_subnet_lb_cidr
#   route_table_id             = oci_core_route_table.oke_public.id
#   security_list_ids          = [oci_core_security_list.oke_lb.id]
#   dns_label                  = "okelb"
#   prohibit_public_ip_on_vnic = false # LB precisa de IP público

#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#     "Purpose"     = "OKE-LoadBalancer"
#   }
# }

# # -----------------------------------------------------
# # Subnet - Pods (VCN Native Pod Networking - privada, grande)
# # -----------------------------------------------------
# resource "oci_core_subnet" "oke_pods" {
#   compartment_id             = var.compartment_id
#   vcn_id                     = oci_core_vcn.oke.id
#   display_name               = "${var.project_name}-oke-subnet-pods"
#   cidr_block                 = var.oke_subnet_pods_cidr
#   route_table_id             = oci_core_route_table.oke_private.id
#   security_list_ids          = [oci_core_security_list.oke_pods.id]
#   dns_label                  = "okepods"
#   prohibit_public_ip_on_vnic = true # Pods em subnet privada

#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#     "Purpose"     = "OKE-Pods-VCN-Native"
#   }
# }

# # -----------------------------------------------------
# # Security List - Databases (PostgreSQL, Redis, etc)
# # -----------------------------------------------------
# resource "oci_core_security_list" "oke_db" {
#   compartment_id = var.compartment_id
#   vcn_id         = oci_core_vcn.oke.id
#   display_name   = "${var.project_name}-oke-sl-db"

#   egress_security_rules {
#     destination = "0.0.0.0/0"
#     protocol    = "all"
#   }

#   # Tráfego interno da VCN (pods, workers)
#   ingress_security_rules {
#     protocol = "all"
#     source   = var.oke_vcn_cidr
#   }

#   # PostgreSQL
#   ingress_security_rules {
#     protocol = "6"
#     source   = var.oke_vcn_cidr
#     tcp_options {
#       min = 5432
#       max = 5432
#     }
#   }

#   # Redis
#   ingress_security_rules {
#     protocol = "6"
#     source   = var.oke_vcn_cidr
#     tcp_options {
#       min = 6379
#       max = 6379
#     }
#   }

#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#     "Subnet"      = "databases"
#   }
# }

# # -----------------------------------------------------
# # Subnet - Databases (privada)
# # -----------------------------------------------------
# resource "oci_core_subnet" "oke_db" {
#   compartment_id             = var.compartment_id
#   vcn_id                     = oci_core_vcn.oke.id
#   display_name               = "${var.project_name}-oke-subnet-db"
#   cidr_block                 = var.oke_subnet_db_cidr
#   route_table_id             = oci_core_route_table.oke_private.id
#   security_list_ids          = [oci_core_security_list.oke_db.id]
#   dns_label                  = "okedb"
#   prohibit_public_ip_on_vnic = true # DBs em subnet privada

#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#     "Purpose"     = "Databases"
#   }
# }
