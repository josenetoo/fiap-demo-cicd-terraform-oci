variable "tenancy_ocid" {
  description = "OCID do Tenancy OCI"
  type        = string
  sensitive   = true
}

variable "user_ocid" {
  description = "OCID do Usuário OCI"
  type        = string
  sensitive   = true
}

variable "fingerprint" {
  description = "Fingerprint da API Key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Região OCI"
  type        = string
  default     = "us-ashburn-1"
}

variable "compartment_id" {
  description = "OCID do Compartment"
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.compartment\\.oc1\\..", var.compartment_id))
    error_message = "O compartment_id deve ser um OCID válido (ocid1.compartment.oc1...)."
  }
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "demo"
}

variable "environment" {
  description = "Ambiente (dev/staging/prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "O environment deve ser: dev, staging ou prod."
  }
}

variable "instance_count" {
  description = "Número de instâncias"
  type        = number
  default     = 2

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 4
    error_message = "O instance_count deve ser entre 1 e 4 (Free Tier)."
  }
}

variable "vcn_cidr" {
  description = "CIDR block da VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block da subnet pública"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_shape" {
  description = "Shape da instância (Free Tier: VM.Standard.E2.1.Micro)"
  type        = string
  default     = "VM.Standard.E2.1.Micro"
}

variable "instance_image_id" {
  description = "OCID da imagem Oracle Linux"
  type        = string
}

variable "ssh_public_key" {
  description = "Chave SSH pública"
  type        = string
  sensitive   = true
}

variable "ingress_ports" {
  description = "Portas TCP de ingress permitidas na security list"
  type        = list(number)
  default     = [22, 80]
}
