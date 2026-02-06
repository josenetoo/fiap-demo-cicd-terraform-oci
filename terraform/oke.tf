# # ============================================================
# # OKE - Oracle Kubernetes Engine
# # ============================================================
# # Equivalente AWS: EKS (Elastic Kubernetes Service)

# # Versões suportadas (2025): v1.32.1, v1.33.1, v1.34.1 (preview)
# # Docs: https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengaboutk8sversions.htm

# # Subnets utilizadas (do networking.tf):
# # - oke_api: API Endpoint (público)
# # - oke_workers: Worker Nodes (privado)
# # - oke_lb: Load Balancers (público)
# # - oke_pods: Pods com VCN Native IP (privado)
# # ============================================================

# # -----------------------------------------------------
# # OKE Cluster com VCN Native Pod Networking
# # -----------------------------------------------------
# resource "oci_containerengine_cluster" "main" {
#   compartment_id     = var.compartment_id
#   kubernetes_version = var.oke_kubernetes_version
#   name               = "${var.project_name}-oke"
#   vcn_id             = oci_core_vcn.oke.id
#   type               = "ENHANCED_CLUSTER"  # Necessário para VCN Native

#   # API Endpoint Configuration
#   endpoint_config {
#     is_public_ip_enabled = true
#     subnet_id            = oci_core_subnet.oke_api.id
#   }

#   # Cluster Options
#   options {
#     # Subnet para Load Balancers criados pelo OKE
#     service_lb_subnet_ids = [oci_core_subnet.oke_lb.id]

#     add_ons {
#       is_kubernetes_dashboard_enabled = false
#       is_tiller_enabled               = false
#     }

#     # Kubernetes Network Config (para services)
#     kubernetes_network_config {
#       services_cidr = var.oke_services_cidr
#     }
#   }

#   # VCN Native Pod Networking
#   cluster_pod_network_options {
#     cni_type = "OCI_VCN_IP_NATIVE"
#   }

#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#     "ManagedBy"   = "Terraform"
#   }
# }

# # -----------------------------------------------------
# # OKE Node Pool - Workers com VCN Native Pod Networking
# # -----------------------------------------------------
# resource "oci_containerengine_node_pool" "main" {
#   cluster_id         = oci_containerengine_cluster.main.id
#   compartment_id     = var.compartment_id
#   kubernetes_version = var.oke_kubernetes_version
#   name               = "${var.project_name}-nodepool"

#   node_shape = var.oke_node_shape

#   node_shape_config {
#     memory_in_gbs = var.oke_node_memory_gb
#     ocpus         = var.oke_node_ocpus
#   }

#   node_config_details {
#     size = var.oke_node_count

#     # Placement em subnet privada de workers
#     placement_configs {
#       availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
#       subnet_id           = oci_core_subnet.oke_workers.id
#     }

#     # VCN Native Pod Networking - Pods usam IPs da subnet de pods
#     node_pool_pod_network_option_details {
#       cni_type          = "OCI_VCN_IP_NATIVE"
#       pod_subnet_ids    = [oci_core_subnet.oke_pods.id]
#       max_pods_per_node = 31
#       pod_nsg_ids       = []
#     }

#     freeform_tags = {
#       "Environment" = var.environment
#       "Project"     = var.project_name
#     }
#   }

#   node_source_details {
#     source_type             = "IMAGE"
#     # Usar imagem configurada na variável
#     image_id                = var.oke_node_image_id
#     boot_volume_size_in_gbs = 50
#   }

#   initial_node_labels {
#     key   = "environment"
#     value = var.environment
#   }

#   ssh_public_key = var.ssh_public_key

#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#   }
# }

# # -----------------------------------------------------
# # NOTA: A imagem OKE deve ser compatível com o shape
# # Para encontrar imagens OKE válidas:
# # OCI Console → Compute → Images → Filtrar por "OKE"
# # Ou usar: oci ce node-pool-options get --node-pool-option-id all
# # -----------------------------------------------------
