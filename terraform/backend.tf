# ============================================================================
# TERRAFORM REMOTE STATE - OCI Object Storage (S3-Compatible)
# ============================================================================

# Por padrão, o backend está DESABILITADO (local state).
# Para habilitar remote state no OCI Object Storage:

# 1. Criar bucket no OCI Object Storage
# 2. Obter Object Storage Namespace
# 3. Criar Customer Secret Keys (credenciais S3-compatible)
# 4. Configurar ~/.aws/credentials com as Customer Secret Keys
# 5. Descomentar o bloco abaixo
# 6. Atualizar valores: namespace, bucket, region
# 7. Executar: terraform init -migrate-state

# Documentação completa: Ver BACKEND-OCI.md
# ============================================================================

terraform {
  backend "s3" {
    # Nome do bucket criado no OCI Object Storage
    bucket = "terraform-state-bucket"
    
    # Caminho do arquivo state dentro do bucket
    key = "fiap-demo/terraform.tfstate"
    
    # Região do bucket (deve corresponder à região do bucket)
    region = "sa-vinhedo-1"
    
    # Endpoint S3-compatible do OCI Object Storage (novo formato)
    endpoints = {
      s3 = "https://ax7pefxfpuix.compat.objectstorage.sa-vinhedo-1.oraclecloud.com"
    }
    
    # Configurações obrigatórias para OCI S3-compatible API
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
  }
}

# ============================================================================
# CREDENCIAIS (NÃO commitar no Git)
# ============================================================================

# O Terraform busca credenciais em ~/.aws/credentials no formato:

# [default]
# aws_access_key_id = <ACCESS_KEY da Customer Secret Key>
# aws_secret_access_key = <SECRET_KEY da Customer Secret Key>

# Para GitHub Actions, configure os secrets:
# - AWS_ACCESS_KEY_ID
# - AWS_SECRET_ACCESS_KEY
# ============================================================================
