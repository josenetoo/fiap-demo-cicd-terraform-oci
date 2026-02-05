# ============================================================================
# TERRAFORM REMOTE STATE - OCI Object Storage (Backend Nativo)
# ============================================================================
#
# Backend OCI nativo: Usa as MESMAS credenciais do provider OCI
# - Requer Terraform >= 1.10.0
# - Não precisa de Customer Secret Keys
# - Não precisa de credenciais AWS
# - Usa ~/.oci/config automaticamente
#
# Configuração:
# 1. Criar bucket no OCI Object Storage
# 2. Obter Object Storage Namespace (veja BACKEND-OCI.md)
# 3. Atualizar valores abaixo: namespace, bucket, region
# 4. Terraform init vai usar credenciais do provider automaticamente
#
# Documentação: https://developer.hashicorp.com/terraform/language/backend/oci
# ============================================================================

terraform {
  required_version = ">= 1.10.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }

  backend "oci" {
    bucket    = "terraform-state-bucket"
    namespace = "ax7pefxfpuix"
    key       = "fiap-demo/terraform.tfstate"
    region    = "sa-vinhedo-1"
  }
}

# ============================================================================
# CREDENCIAIS (Mesmas do Provider OCI)
# ============================================================================
#
# O backend OCI usa as MESMAS credenciais configuradas para o provider:
# - Localmente: ~/.oci/config
# - GitHub Actions: Configurado no step "Configure OCI Credentials"
#
# Não precisa de secrets adicionais!
# ============================================================================
