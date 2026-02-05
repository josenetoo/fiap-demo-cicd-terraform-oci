# 🚀 Terraform + GitHub Actions + Oracle Cloud Infrastructure

Projeto demonstrativo de Infrastructure as Code usando Terraform com pipeline CI/CD automatizado no GitHub Actions para provisionar recursos na Oracle Cloud.

## 📋 Pré-requisitos

- Conta Oracle Cloud (Free Tier disponível)
- Conta GitHub
- Terraform >= 1.6.0 (para testes locais)

## 🏗️ Arquitetura

Este projeto provisiona:
- **VCN (Virtual Cloud Network)** com Internet Gateway, NAT Gateway e Service Gateway
- **Compute Instances** (2x VM.Standard.E2.1.Micro - Always Free)
- Configuração completa de rede e segurança

## 📁 Estrutura do Projeto

```
📁 terraform-oci-demo/
├── 📁 .github/workflows/
│   ├── terraform-plan.yml      # Pipeline de validação (PRs)
│   └── terraform-apply.yml     # Pipeline de deploy (merge)
├── 📁 terraform/
│   ├── main.tf                 # Recursos principais
│   ├── variables.tf            # Variáveis de entrada
│   ├── outputs.tf              # Outputs importantes
│   ├── provider.tf             # Provider OCI
│   └── backend.tf              # Remote state (Object Storage)
├── .gitignore
└── README.md
```

## 🔐 Configuração de Secrets

Configure os seguintes secrets no GitHub (Settings → Secrets and variables → Actions):

| Secret | Descrição |
|--------|-----------|
| `OCI_TENANCY_OCID` | OCID do tenancy |
| `OCI_USER_OCID` | OCID do usuário |
| `OCI_FINGERPRINT` | Fingerprint da API Key |
| `OCI_PRIVATE_KEY` | Chave privada (base64) |
| `OCI_REGION` | Região (ex: us-ashburn-1) |
| `OCI_COMPARTMENT_ID` | OCID do compartment |

### Como obter as credenciais OCI:

1. **Criar API Key no console OCI:**
   - Profile → User Settings → API Keys → Add API Key

2. **Converter chave privada para base64:**
   ```bash
   cat ~/.oci/oci_api_key.pem | base64 -w 0
   ```

3. **Obter fingerprint:**
   ```bash
   cat ~/.oci/config | grep fingerprint
   ```

## 🔄 Fluxo de Trabalho

### 1. Pull Request (Validação)
```bash
git checkout -b feature/nova-funcionalidade
# Faça alterações no código Terraform
git add .
git commit -m "Adiciona nova funcionalidade"
git push origin feature/nova-funcionalidade
```
- ✅ Pipeline `terraform-plan` executa automaticamente
- ✅ Comentário com o plan aparece no PR

### 2. Merge to Main (Deploy)
```bash
# Após aprovação, merge o PR
```
- ✅ Pipeline `terraform-apply` executa automaticamente
- ✅ Requer aprovação manual (environment: production)
- ✅ Recursos são provisionados na OCI

## 🧪 Testes Locais

```bash
cd terraform

# Configure credenciais
export TF_VAR_tenancy_ocid="ocid1.tenancy..."
export TF_VAR_user_ocid="ocid1.user..."
export TF_VAR_fingerprint="aa:bb:cc..."
export TF_VAR_compartment_id="ocid1.compartment..."
export TF_VAR_region="us-ashburn-1"
export TF_VAR_ssh_public_key="ssh-rsa AAAA..."

# Inicialize Terraform
terraform init

# Valide configuração
terraform validate

# Veja o plano
terraform plan

# Aplique (opcional)
terraform apply
```

## 💰 Recursos OCI Free Tier

Recursos **Always Free** utilizados:
- ✅ 2x Compute VM.Standard.E2.1.Micro (1 OCPU, 1GB RAM)
- ✅ 1x VCN com gateways
- ✅ 10GB Object Storage (para remote state)

## 🛡️ Segurança e Best Practices

### ✅ Implementado:
- Módulos oficiais e versionados
- Credenciais em GitHub Secrets
- Remote state (Object Storage)
- Aprovação manual para produção
- Validação de código (fmt, validate)
- Tags em todos os recursos

### ⚠️ Importante:
- Nunca commitar credenciais no código
- Sempre validar antes do apply
- Usar versões fixadas de módulos
- Documentar todas as mudanças

## 🔧 Troubleshooting

### Erro: "Service error: NotAuthenticated"
Verificar credenciais OCI e secrets do GitHub

### Erro: "out of host capacity"
Trocar availability domain (`ad_number = 2` ou `3`)

### Erro: "shape not available"
Usar shape Always Free: `VM.Standard.E2.1.Micro`

## 📚 Recursos Adicionais

- [Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [Oracle Terraform Modules](https://registry.terraform.io/namespaces/oracle-terraform-modules)
- [OCI Free Tier](https://www.oracle.com/cloud/free/)
- [GitHub Actions Docs](https://docs.github.com/en/actions)

## 🎓 Informações da Aula

**Professor:** José Neto  
**Curso:** Arquitetura de Sistemas - FIAP  
**Tema:** Infrastructure as Code com Terraform + CI/CD  

---

**🚀 Happy Terraforming!**
