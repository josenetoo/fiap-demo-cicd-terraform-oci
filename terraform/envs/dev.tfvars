# ============================================================================
# Configuração do Ambiente DEV
# ============================================================================
#
# Variáveis NÃO sensíveis do projeto.
# Credenciais ficam nos GitHub Secrets.
#
# Para outros ambientes, crie: staging.tfvars, prod.tfvars
# ============================================================================

# --- Projeto ---
project_name = "fiap-demo-oci"
environment  = "dev"

# --- Rede ---
vcn_cidr    = "10.0.0.0/16"
subnet_cidr = "10.0.1.0/24"

# --- Compute ---
instance_image_id = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaa3isvzt4wyrlth6etis4ekiwaxpqjznsknrk3jbwka5uonkuvbewa"
instance_shape    = "VM.Standard.E4.Flex"
instance_count    = 2

# --- Security ---
ingress_ports = [22, 80]
