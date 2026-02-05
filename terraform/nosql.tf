# # -----------------------------------------------------
# # NoSQL Table - ToggleMasterAnalytics
# # -----------------------------------------------------
# resource "oci_nosql_table" "toggle_master_analytics" {
#   compartment_id = var.compartment_id
#   name           = "ToggleMasterAnalytics"
#   ddl_statement  = <<-EOT
#     CREATE TABLE IF NOT EXISTS ToggleMasterAnalytics (
#       id STRING,
#       feature_name STRING,
#       enabled BOOLEAN,
#       user_id STRING,
#       timestamp TIMESTAMP(3),
#       metadata JSON,
#       PRIMARY KEY (id)
#     )
#   EOT

#   table_limits {
#     max_read_units     = var.nosql_read_units
#     max_write_units    = var.nosql_write_units
#     max_storage_in_gbs = var.nosql_storage_gb
#   }

#   is_auto_reclaimable = false

#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#     "Table"       = "ToggleMasterAnalytics"
#   }
# }

# # -----------------------------------------------------
# # NoSQL Index - Por feature_name (para queries)
# # -----------------------------------------------------
# resource "oci_nosql_index" "toggle_by_feature" {
#   table_name_or_id = oci_nosql_table.toggle_master_analytics.id
#   name             = "idx_feature_name"

#   keys {
#     column_name = "feature_name"
#   }

#   compartment_id = var.compartment_id
# }

# # -----------------------------------------------------
# # NoSQL Index - Por user_id (para queries por usuário)
# # -----------------------------------------------------
# resource "oci_nosql_index" "toggle_by_user" {
#   table_name_or_id = oci_nosql_table.toggle_master_analytics.id
#   name             = "idx_user_id"

#   keys {
#     column_name = "user_id"
#   }

#   compartment_id = var.compartment_id
# }
