# # ============================================================
# # REGISTRY - OCI Container Registry (OCIR)
# # ============================================================
# # Equivalente AWS: ECR (Elastic Container Registry)

# # -----------------------------------------------------
# # Container Repository 1 - API Gateway
# # -----------------------------------------------------
# resource "oci_artifacts_container_repository" "api_gateway" {
#   compartment_id = var.compartment_id
#   display_name   = "${var.project_name}/api-gateway"
#   is_public      = false
#   is_immutable   = false

#   readme {
#     content = "API Gateway service container images"
#     format  = "text/plain"
#   }
# }

# # -----------------------------------------------------
# # Container Repository 2 - User Service
# # -----------------------------------------------------
# resource "oci_artifacts_container_repository" "user_service" {
#   compartment_id = var.compartment_id
#   display_name   = "${var.project_name}/user-service"
#   is_public      = false
#   is_immutable   = false

#   readme {
#     content = "User service container images"
#     format  = "text/plain"
#   }
# }

# # -----------------------------------------------------
# # Container Repository 3 - Order Service
# # -----------------------------------------------------
# resource "oci_artifacts_container_repository" "order_service" {
#   compartment_id = var.compartment_id
#   display_name   = "${var.project_name}/order-service"
#   is_public      = false
#   is_immutable   = false

#   readme {
#     content = "Order service container images"
#     format  = "text/plain"
#   }
# }

# # -----------------------------------------------------
# # Container Repository 4 - Payment Service
# # -----------------------------------------------------
# resource "oci_artifacts_container_repository" "payment_service" {
#   compartment_id = var.compartment_id
#   display_name   = "${var.project_name}/payment-service"
#   is_public      = false
#   is_immutable   = false

#   readme {
#     content = "Payment service container images"
#     format  = "text/plain"
#   }
# }

# # -----------------------------------------------------
# # Container Repository 5 - Notification Service
# # -----------------------------------------------------
# resource "oci_artifacts_container_repository" "notification_service" {
#   compartment_id = var.compartment_id
#   display_name   = "${var.project_name}/notification-service"
#   is_public      = false
#   is_immutable   = false

#   readme {
#     content = "Notification service container images"
#     format  = "text/plain"
#   }
# }