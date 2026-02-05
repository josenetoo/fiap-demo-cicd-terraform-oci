# 🚀 Terraform + GitHub Actions + Oracle Cloud Infrastructure

Projeto demonstrativo de Infrastructure as Code usando Terraform com pipeline CI/CD automatizado no GitHub Actions para provisionar recursos na Oracle Cloud.

## 📋 Pré-requisitos

- Conta Oracle Cloud (Free Tier disponível)
- Conta GitHub
- Terraform >= 1.6.0 (para testes locais)

## 🏗️ Arquitetura

### Recursos Provisionados

Este projeto usa **módulos oficiais da Oracle** e recursos nativos:

**Rede (via módulo `oracle-terraform-modules/vcn/oci`):**
- 1x VCN (10.0.0.0/16)
- 1x Internet Gateway
- 1x Route Table com rota para internet

**Subnet e Segurança (recursos nativos):**
- 1x Subnet pública (10.0.1.0/24)
- 1x Security List (SSH porta 22, HTTP porta 80)

**Compute (via módulo `oracle-terraform-modules/compute-instance/oci`):**
- 2x Compute Instances VM.Standard.E2.1.Micro (Always Free)
- IPs públicos atribuídos automaticamente
- Acesso SSH configurado

### Diagrama de Infraestrutura

```
┌─────────────────────────────────────────┐
│           OCI Compartment               │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  VCN (10.0.0.0/16)                │ │
│  │                                   │ │
│  │  ┌─────────────────────────────┐ │ │
│  │  │  Internet Gateway           │ │ │
│  │  └──────────┬──────────────────┘ │ │
│  │             │                     │ │
│  │  ┌──────────▼──────────────────┐ │ │
│  │  │  Public Subnet              │ │ │
│  │  │  (10.0.1.0/24)              │ │ │
│  │  │                             │ │ │
│  │  │  ┌──────────┐  ┌──────────┐│ │ │
│  │  │  │Instance-0│  │Instance-1││ │ │
│  │  │  │  (FREE)  │  │  (FREE)  ││ │ │
│  │  │  └────┬─────┘  └────┬─────┘│ │ │
│  │  │       │             │       │ │ │
│  │  │    Public IP     Public IP  │ │ │
│  │  └─────────────────────────────┘ │ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

## 📁 Estrutura do Projeto

```
📁 fiap-demo-cicd-terraform-oci/
├── 📁 .github/workflows/
│   ├── terraform-plan.yml      # Pipeline de validação (PRs)
│   ├── terraform-apply.yml     # Pipeline de deploy (manual)
│   └── terraform-destroy.yml   # Pipeline de limpeza (manual)
├── 📁 terraform/
│   ├── main.tf                 # Recursos principais (VCN module + Compute module)
│   ├── variables.tf            # Variáveis de entrada
│   ├── outputs.tf              # Outputs importantes
│   ├── provider.tf             # Provider OCI
│   ├── backend.tf              # Remote state (desabilitado por padrão)
│   └── terraform.tfvars        # Valores locais (gitignored)
├── .gitignore
├── README.md
├── HANDS-ON.md                 # Guia passo a passo
└── terraform.md                # Documentação técnica
```

## 🔐 Configuração de Secrets no GitHub

Configure os seguintes secrets no GitHub (Settings → Secrets and variables → Actions):

### Secrets Obrigatórios (Credenciais OCI)

| Secret | Descrição | Exemplo |
|--------|-----------|---------|
| `OCI_TENANCY_OCID` | OCID do tenancy | `ocid1.tenancy.oc1..aaaaaaaaa...` |
| `OCI_USER_OCID` | OCID do usuário | `ocid1.user.oc1..aaaaaaaaa...` |
| `OCI_FINGERPRINT` | Fingerprint da API Key | `aa:bb:cc:dd:ee:ff:...` |
| `OCI_PRIVATE_KEY` | Chave privada em base64 **sem quebras de linha** | `LS0tLS1CRUdJTi...` |
| `OCI_REGION` | Região OCI | `sa-vinhedo-1` ou `us-ashburn-1` |
| `OCI_COMPARTMENT_ID` | OCID do compartment | `ocid1.compartment.oc1..aaaaaaaaa...` |

### Secrets de Configuração do Terraform

| Secret | Descrição | Valor Padrão |
|--------|-----------|--------------|
| `OCI_INSTANCE_IMAGE_ID` | OCID da imagem Oracle Linux | `ocid1.image.oc1.sa-vinhedo-1.aaaaaaaa...` |
| `OCI_SSH_PUBLIC_KEY` | Chave SSH pública completa | `ssh-rsa AAAAB3NzaC1yc2EAAAA...` |
| `OCI_PROJECT_NAME` | Nome do projeto | `fiap-demo` |
| `OCI_ENVIRONMENT` | Ambiente (dev/staging/prod) | `dev` |
| `OCI_INSTANCE_COUNT` | Número de instâncias | `2` |

### Como obter as credenciais OCI:

#### 1. Criar API Key no Console OCI

1. Acesse: https://cloud.oracle.com
2. Clique no **ícone do perfil** (canto superior direito)
3. Selecione: **User Settings**
4. No menu lateral: **API Keys**
5. Clique em: **Add API Key**
6. Selecione: **Generate API Key Pair**
7. **Download Private Key** (salve como `oci_api_key.pem`)
8. **Download Public Key** (salve como `oci_api_key_public.pem`)
9. Clique em: **Add**
10. **Copie os valores** que aparecem na tela (user, fingerprint, tenancy, region)

#### 2. Converter Chave Privada para Base64

**Mac/Linux:**
```bash
cd ~/Downloads
cat oci_api_key.pem | base64 | tr -d '\n' > oci_api_key_base64.txt
cat oci_api_key_base64.txt
```

**Windows (PowerShell):**
```powershell
cd $HOME\Downloads
[Convert]::ToBase64String([IO.File]::ReadAllBytes("oci_api_key.pem")) | Out-File -Encoding ASCII oci_api_key_base64.txt
Get-Content oci_api_key_base64.txt
```

⚠️ **IMPORTANTE:** O base64 deve ser uma **única linha** sem quebras!

#### 3. Obter Compartment ID

1. No menu OCI: ☰ → **Identity & Security** → **Compartments**
2. Clique no compartment desejado
3. Copie o **OCID**

#### 4. Obter Image OCID (Oracle Linux)

**Opção 1 - Via Console:**
1. Menu: ☰ → **Compute** → **Instances**
2. Clique em: **Create Instance**
3. Em "Image": Clique em **Change Image**
4. Selecione: **Oracle Linux 8**
5. **Copie o OCID** da imagem
6. Cancele a criação

**Opção 2 - Via OCI CLI:**
```bash
oci compute image list \
  --compartment-id <SEU_COMPARTMENT_ID> \
  --operating-system "Oracle Linux" \
  --operating-system-version "8" \
  --shape "VM.Standard.E2.1.Micro" \
  --query 'data[0].id' \
  --raw-output
```

#### 5. Gerar Chave SSH

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/oci_demo_key -N ""
cat ~/.ssh/oci_demo_key.pub
```

## 🔄 Pipelines e Fluxo de Trabalho

### Pipeline 1: Terraform Plan (Automático em PRs)

**Trigger:** Pull Request para `main`

**Executa:**
1. `terraform fmt -check` - Valida formatação
2. `terraform init` - Inicializa providers e módulos
3. `terraform validate` - Valida sintaxe
4. `terraform plan` - Gera plano de execução
5. Comenta o plano no PR automaticamente

### Pipeline 2: Terraform Apply (Manual)

**Trigger:** Execução manual via GitHub Actions

**Executa:**
1. `terraform init`
2. `terraform plan -out=tfplan`
3. **Pausa para aprovação manual** (environment: production)
4. `terraform apply -auto-approve tfplan`
5. Gera outputs em JSON
6. Upload dos outputs como artifact

### Pipeline 3: Terraform Destroy (Manual)

**Trigger:** Execução manual via GitHub Actions

**Executa:**
1. `terraform init`
2. **Pausa para aprovação manual** (environment: production)
3. `terraform destroy -auto-approve`

## 🎯 Fluxo de Trabalho GitOps

### 1. Desenvolvimento e Validação
```bash
# Criar branch de feature
git checkout -b feature/nova-funcionalidade

# Fazer alterações no código Terraform
vim terraform/main.tf

# Commit e push
git add .
git commit -m "feat: Adiciona nova funcionalidade"
git push origin feature/nova-funcionalidade

# Abrir PR no GitHub
# ✅ Pipeline terraform-plan executa automaticamente
# ✅ Comentário com o plan aparece no PR
```

### 2. Deploy Manual
```bash
# Via GitHub Actions:
# 1. Actions → Terraform Apply → Run workflow
# 2. Selecionar branch: main
# 3. Run workflow
# 4. Aguardar aprovação manual
# 5. Approve and deploy
# ✅ Recursos provisionados na OCI
```

### 3. Destruir Recursos
```bash
# Via GitHub Actions:
# 1. Actions → Terraform Destroy → Run workflow
# 2. Selecionar branch: main
# 3. Run workflow
# 4. Aguardar aprovação manual
# 5. Approve and deploy
# ✅ Recursos removidos da OCI
```

## 🧪 Testes Locais

### Configurar Credenciais Localmente

```bash
# Criar diretório OCI
mkdir -p ~/.oci

# Copiar chave privada
cp ~/Downloads/oci_api_key.pem ~/.oci/
chmod 600 ~/.oci/oci_api_key.pem

# Criar arquivo de configuração
cat > ~/.oci/config << EOF
[DEFAULT]
user=ocid1.user.oc1..aaaaaaaa...
fingerprint=aa:bb:cc:dd:ee:ff:...
tenancy=ocid1.tenancy.oc1..aaaaaaaa...
region=sa-vinhedo-1
key_file=~/.oci/oci_api_key.pem
EOF
```

### Criar terraform.tfvars Local

```bash
cd terraform
cat > terraform.tfvars << EOF
project_name      = "fiap-demo"
environment       = "dev"
instance_count    = 2
instance_image_id = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaa..."
ssh_public_key    = "ssh-rsa AAAAB3NzaC1yc2EAAAA..."
EOF
```

### Executar Terraform

```bash
# Exportar variáveis de credenciais
export TF_VAR_tenancy_ocid="ocid1.tenancy.oc1..aaaaaaaa..."
export TF_VAR_user_ocid="ocid1.user.oc1..aaaaaaaa..."
export TF_VAR_fingerprint="aa:bb:cc:dd:ee:ff:..."
export TF_VAR_region="sa-vinhedo-1"
export TF_VAR_compartment_id="ocid1.compartment.oc1..aaaaaaaa..."

# Inicializar Terraform
terraform init

# Validar configuração
terraform validate

# Formatar código
terraform fmt

# Ver plano de execução
terraform plan

# Aplicar mudanças
terraform apply

# Ver outputs
terraform output

# Destruir recursos
terraform destroy
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
