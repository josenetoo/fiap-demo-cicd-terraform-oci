variable "tenancy_ocid" {
  description = "OCID do Tenancy OCI"
  type        = string
}

variable "user_ocid" {
  description = "OCID do Usuário OCI"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint da API Key"
  type        = string
}

variable "region" {
  description = "Região OCI"
  type        = string
  default     = "us-ashburn-1"
}

variable "compartment_id" {
  description = "OCID do Compartment"
  type        = string
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
}

variable "instance_count" {
  description = "Número de instâncias"
  type        = number
  default     = 2
}

variable "instance_image_id" {
  description = "OCID da imagem Oracle Linux"
  type        = string
  default = "ocid1.image.oc1.iad.aaaaaaaa..."
}

variable "ssh_public_key" {
  description = "Chave SSH pública"
  type        = string
}
