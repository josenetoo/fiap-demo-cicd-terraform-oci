# 🚀 Terraform + GitHub Actions + Oracle Cloud Infrastructure

Projeto demonstrativo de Infrastructure as Code usando Terraform com pipeline CI/CD automatizado no GitHub Actions para provisionar recursos na Oracle Cloud.

## 📋 Pré-requisitos

- Conta Oracle Cloud (Free Tier disponível)
- Conta GitHub (repositório público para environment protection rules)
- Terraform >= 1.10.0 (para testes locais)

## 🏗️ Arquitetura

### Recursos Provisionados

**Rede (módulo `oracle-terraform-modules/vcn/oci` v3.6.0):**
- 1x VCN
- 1x Internet Gateway
- 1x Route Table

**Subnet e Segurança (recursos nativos):**
- 1x Subnet pública
- 1x Security List (portas configuráveis via `ingress_ports`)

**Compute (módulo `oracle-terraform-modules/compute-instance/oci` v2.4.0):**
- Instâncias configuráveis (shape e quantidade via `envs/dev.tfvars`)
- IPs públicos atribuídos automaticamente
- Acesso SSH configurado

### Diagrama

```
┌─────────────────────────────────────────┐
│           OCI Compartment               │
│  ┌───────────────────────────────────┐ │
│  │  VCN (var.vcn_cidr)               │ │
│  │  ┌─────────────────────────────┐ │ │
│  │  │  Internet Gateway           │ │ │
│  │  └──────────┬──────────────────┘ │ │
│  │  ┌──────────▼──────────────────┐ │ │
│  │  │  Public Subnet              │ │ │
│  │  │  (var.subnet_cidr)          │ │ │
│  │  │  ┌──────────┐  ┌──────────┐│ │ │
│  │  │  │Instance-0│  │Instance-1││ │ │
│  │  │  └────┬─────┘  └────┬─────┘│ │ │
│  │  │    Public IP     Public IP  │ │ │
│  │  └─────────────────────────────┘ │ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

## 📁 Estrutura do Projeto

```
📁 fiap-demo-cicd-terraform-oci/
├── 📁 .github/workflows/
│   ├── terraform-plan.yml        # Pipeline Plan (automático no push)
│   ├── terraform-apply.yml       # Pipeline Apply (manual + aprovação)
│   └── terraform-destroy.yml     # Pipeline Destroy (manual + aprovação)
├── 📁 terraform/
│   ├── backend.tf                # Backend OCI nativo + providers
│   ├── provider.tf               # Provider OCI
│   ├── main.tf                   # Recursos (VCN, Subnet, Compute)
│   ├── variables.tf              # Variáveis com validações
│   ├── outputs.tf                # Outputs
│   └── 📁 envs/
│       └── dev.tfvars            # Configuração do ambiente dev (commitado)
├── .gitignore
├── README.md
├── HANDS-ON.md
└── BACKEND-OCI.md
```

## 🔄 Pipelines (3 separadas)

### Pipeline 1: Terraform Plan (Automático)

**Trigger:** Push na `main` (alterações em `terraform/**`) + manual

**Executa:** `init` → `validate` → `plan`

### Pipeline 2: Terraform Apply (Manual + Aprovação)

**Trigger:** Manual via GitHub Actions

**Executa:** `init` → `plan` → ⏸️ **Aprovação (environment: dev)** → `apply` → `output`

### Pipeline 3: Terraform Destroy (Manual + Aprovação)

**Trigger:** Manual via GitHub Actions

**Executa:** `init` → ⏸️ **Aprovação (environment: dev)** → `destroy`

### Fluxo Visual

```
1️⃣  git push origin main
         │
         ▼
   ┌──────────────┐
   │ 🔍 Plan      │  ← Automático
   │ (validação)  │
   └──────┬───────┘
          │ ✅ Plan OK → Revisar output
          ▼
2️⃣  Actions → Terraform Apply → Run workflow
         │
   ┌──────────────┐
   │ ⏸️ Aprovação  │  ← Environment: dev
   └──────┬───────┘
          │ 👍 Approved
          ▼
   ┌──────────────┐
   │ 🚀 Apply     │  ← Recursos criados!
   └──────────────┘

3️⃣  Actions → Terraform Destroy → Run workflow (quando necessário)
```

## 🔐 Configuração

### GitHub Secrets (7 - apenas credenciais)

| Secret | Descrição |
|--------|-----------|
| `OCI_TENANCY_OCID` | OCID do tenancy |
| `OCI_USER_OCID` | OCID do usuário |
| `OCI_FINGERPRINT` | Fingerprint da API Key |
| `OCI_PRIVATE_KEY` | Chave privada em base64 (sem quebras de linha) |
| `OCI_REGION` | Região OCI (ex: `sa-vinhedo-1`) |
| `OCI_COMPARTMENT_ID` | OCID do compartment |
| `OCI_SSH_PUBLIC_KEY` | Chave SSH pública |

### GitHub Environment

Criar environment `dev` com **Required reviewers** em:
Settings → Environments → New environment → `dev` → Required reviewers

### Variáveis do Projeto (`terraform/envs/dev.tfvars`)

Valores editáveis do projeto, commitados no repositório:

```hcl
# --- Projeto ---
project_name = "fiap-demo-oci"
environment  = "dev"

# --- Rede ---
vcn_cidr    = "10.0.0.0/16"
subnet_cidr = "10.0.1.0/24"

# --- Compute ---
instance_image_id = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaa..."
instance_shape    = "VM.Standard.E4.Flex"
instance_count    = 2

# --- Security ---
ingress_ports = [22, 80]
```

## 🔑 Como Obter as Credenciais OCI

### 1. Criar API Key

1. Console OCI → **Perfil** → **User Settings** → **API Keys** → **Add API Key**
2. **Generate API Key Pair** → Download Private + Public Key
3. Copiar valores: user, fingerprint, tenancy, region

### 2. Converter Chave Privada para Base64

```bash
cat oci_api_key.pem | base64 | tr -d '\n'
```

### 3. Obter Compartment ID

Menu OCI: ☰ → **Identity & Security** → **Compartments** → Copiar OCID

### 4. Obter Image OCID

Menu OCI: ☰ → **Compute** → **Images** → Filtrar Oracle Linux → Copiar OCID

### 5. Gerar Chave SSH

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/oci_demo_key -N ""
cat ~/.ssh/oci_demo_key.pub
```

## 🧪 Testes Locais

```bash
# 1. Configurar credenciais
mkdir -p ~/.oci
cp oci_api_key.pem ~/.oci/
chmod 600 ~/.oci/oci_api_key.pem

# 2. Exportar variáveis sensíveis
export TF_VAR_tenancy_ocid="ocid1.tenancy.oc1..aaaaaaaa..."
export TF_VAR_user_ocid="ocid1.user.oc1..aaaaaaaa..."
export TF_VAR_fingerprint="aa:bb:cc:dd:ee:ff:..."
export TF_VAR_region="sa-vinhedo-1"
export TF_VAR_compartment_id="ocid1.compartment.oc1..aaaaaaaa..."
export TF_VAR_ssh_public_key="ssh-rsa AAAAB3..."

# 3. Executar
cd terraform
terraform init
terraform plan -var-file=envs/dev.tfvars
terraform apply -var-file=envs/dev.tfvars
terraform destroy -var-file=envs/dev.tfvars
```

## �️ Segurança

- ✅ Credenciais isoladas em GitHub Secrets (7 secrets)
- ✅ Variáveis de projeto em `envs/dev.tfvars` (versionado, sem dados sensíveis)
- ✅ Variables com `sensitive = true` e validações
- ✅ Remote state com Backend OCI nativo
- ✅ Aprovação manual via environment protection rules
- ✅ Módulos oficiais Oracle versionados
- ✅ Zero valores hardcoded no código Terraform

## 🔧 Troubleshooting

| Erro | Solução |
|------|---------|
| `NotAuthenticated` | Verificar credenciais OCI e secrets |
| `out of host capacity` | Trocar `ad_number` no main.tf |
| `shape not available` | Alterar `instance_shape` no dev.tfvars |
| `Invalid compartment_id` | Verificar OCID (aceita tenancy ou compartment) |

## 📚 Recursos

- [Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [Terraform OCI Backend](https://developer.hashicorp.com/terraform/language/backend/oci)
- [Oracle Terraform Modules](https://registry.terraform.io/namespaces/oracle-terraform-modules)
- [OCI Free Tier](https://www.oracle.com/cloud/free/)

## 🎓 Informações da Aula

**Professor:** José Neto
**Curso:** Arquitetura de Sistemas - FIAP
**Tema:** Infrastructure as Code com Terraform + CI/CD

---

**🚀 Happy Terraforming!**
