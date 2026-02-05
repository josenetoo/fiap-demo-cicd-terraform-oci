# 🎓 HANDS-ON: Terraform + GitHub Actions + Oracle Cloud

**Guia prático para a aula**

---

## 📋 Pré-requisitos

- [ ] Conta Oracle Cloud (Free Tier) - https://www.oracle.com/cloud/free/
- [ ] Conta GitHub
- [ ] Git instalado localmente

---

## 🚀 PARTE 1: Configurar Credenciais OCI (15 min)

### Passo 1: Criar API Key na OCI

1. Acesse: https://cloud.oracle.com
2. **Perfil** (canto superior direito) → **User Settings**
3. Menu lateral: **API Keys** → **Add API Key**
4. **Generate API Key Pair**
5. **Download Private Key** → salvar como `oci_api_key.pem`
6. **Add** → **NÃO FECHE A TELA!**

### Passo 2: Copiar Credenciais

Na tela que apareceu, copie para um bloco de notas:

```ini
user=ocid1.user.oc1..aaaaaaaa...
fingerprint=aa:bb:cc:dd:ee:ff:...
tenancy=ocid1.tenancy.oc1..aaaaaaaa...
region=sa-vinhedo-1
```

### Passo 3: Obter Compartment ID

Menu OCI: ☰ → **Identity & Security** → **Compartments** → Copiar OCID

### Passo 4: Converter Chave Privada para Base64

**Mac/Linux:**
```bash
cat ~/Downloads/oci_api_key.pem | base64 | tr -d '\n'
# Copie o resultado inteiro (uma única linha)
```

**Windows (PowerShell):**
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("$HOME\Downloads\oci_api_key.pem"))
# Copie o resultado inteiro (uma única linha)
```

**Windows (CMD):**
```cmd
certutil -encode %USERPROFILE%\Downloads\oci_api_key.pem tmp.b64 && findstr /v /c:- tmp.b64 && del tmp.b64
```

⚠️ **IMPORTANTE:** O resultado deve ser uma **única linha** sem quebras e sem espaços!

### Passo 5: Gerar Chave SSH

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/oci_demo_key -N ""
cat ~/.ssh/oci_demo_key.pub
```

### ✅ Checklist - Você deve ter:

```
✓ user          → OCI_USER_OCID
✓ fingerprint   → OCI_FINGERPRINT
✓ tenancy       → OCI_TENANCY_OCID
✓ region        → OCI_REGION
✓ compartment   → OCI_COMPARTMENT_ID
✓ base64 key    → OCI_PRIVATE_KEY
✓ ssh pub key   → OCI_SSH_PUBLIC_KEY
```

---

## 🔧 PARTE 2: Configurar Repositório GitHub (10 min)

### Passo 1: Fork ou Clone do Projeto

```bash
git clone https://github.com/SEU-USUARIO/fiap-demo-cicd-terraform-oci.git
cd fiap-demo-cicd-terraform-oci
```

### Passo 2: Configurar GitHub Secrets (7 secrets)

**Settings** → **Secrets and variables** → **Actions** → **New repository secret**

| Secret | Valor |
|--------|-------|
| `OCI_TENANCY_OCID` | `ocid1.tenancy.oc1..aaaaaaaa...` |
| `OCI_USER_OCID` | `ocid1.user.oc1..aaaaaaaa...` |
| `OCI_FINGERPRINT` | `aa:bb:cc:dd:ee:ff:...` |
| `OCI_PRIVATE_KEY` | Base64 da chave privada (sem quebras) |
| `OCI_REGION` | `sa-vinhedo-1` |
| `OCI_COMPARTMENT_ID` | `ocid1.compartment.oc1..aaaaaaaa...` |
| `OCI_SSH_PUBLIC_KEY` | `ssh-rsa AAAAB3NzaC1yc2EAAAA...` |

**Total: 7 secrets**

### Passo 3: Criar Environment "dev"

1. **Settings** → **Environments** → **New environment**
2. **Name:** `dev`
3. ✅ **Required reviewers** → Adicionar seu username
4. **Save protection rules**

---

## 📝 PARTE 3: Configurar Variáveis do Projeto (5 min)

### Passo 1: Obter Image OCID

Menu OCI: ☰ → **Compute** → **Images** → Filtrar Oracle Linux → Copiar OCID

### Passo 2: Editar `terraform/envs/dev.tfvars`

```hcl
# --- Projeto ---
project_name = "fiap-demo-oci"
environment  = "dev"

# --- Rede ---
vcn_cidr    = "10.0.0.0/16"
subnet_cidr = "10.0.1.0/24"

# --- Compute ---
instance_image_id = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaa..."  # ← OCID da imagem
instance_shape    = "VM.Standard.E4.Flex"
instance_count    = 2

# --- Security ---
ingress_ports = [22, 80]
```

**Este arquivo é commitado no repo** (não é sensível).

---

## 🚀 PARTE 4: Deploy via GitHub Actions (15 min)

### Passo 1: Commit e Push

```bash
git add .
git commit -m "feat: Configure infrastructure"
git push origin main
```

### Passo 2: Verificar Plan Automático

1. Vá em **Actions** no GitHub
2. A pipeline **Terraform Plan** está rodando automaticamente
3. Aguarde finalizar e revise o output

### Passo 3: Executar Apply

1. **Actions** → **Terraform Apply** → **Run workflow** → **Run workflow**
2. A pipeline vai pausar pedindo **aprovação**
3. Clique em **Review deployments** → ✅ **Approve and deploy**
4. Aguarde 3-5 minutos

### Passo 4: Verificar na OCI

1. **VCN:** ☰ → Networking → Virtual Cloud Networks
2. **Instâncias:** ☰ → Compute → Instances
3. Copiar IPs públicos

### Passo 5: Testar SSH

```bash
ssh -i ~/.ssh/oci_demo_key opc@<IP_PUBLICO>
whoami
hostname
exit
```

---

## 📊 PARTE 5: Ver Outputs (2 min)

1. **Actions** → Última execução do **Terraform Apply**
2. **Artifacts** → Download **terraform-outputs**
3. Abrir `outputs.json`

---

## 🔄 PARTE 6: Demonstrar Mudança (5 min)

### Mostrar o ciclo completo:

```bash
# 1. Alterar algo no dev.tfvars (ex: adicionar porta 443)
# ingress_ports = [22, 80, 443]

# 2. Commit e push
git add .
git commit -m "feat: Add HTTPS port 443"
git push origin main

# 3. Plan roda automaticamente → Revisar
# 4. Run Apply manualmente → Aprovar
# 5. Verificar mudança na OCI
```

---

## 🧹 PARTE 7: Destruir Recursos (IMPORTANTE!)

### Via GitHub Actions:

1. **Actions** → **Terraform Destroy** → **Run workflow**
2. **Aprovar** quando pedir
3. Aguardar destruição

### Verificar na OCI:

- Compute → Instances → Vazio
- Networking → VCN → Vazio

---

## 🐛 Troubleshooting

| Erro | Solução |
|------|---------|
| `NotAuthenticated` | Verificar secrets no GitHub |
| `out of host capacity` | Trocar `ad_number` no main.tf |
| `shape not available` | Alterar `instance_shape` no dev.tfvars |
| `Invalid private key` | Base64 sem espaços/quebras de linha |
| `Invalid compartment_id` | Aceita `ocid1.tenancy...` ou `ocid1.compartment...` |
| Plan não executa | Verificar se alterou arquivos em `terraform/**` |

---

## 🎓 Fluxo Resumido

```
Push → Plan (auto) → Revisar → Apply (manual) → Aprovar → Deploy
                                                          ↓
                              Destroy (manual) → Aprovar → Cleanup
```

**Professor:** José Neto
**Curso:** Arquitetura de Sistemas - FIAP
**Tema:** Infrastructure as Code com Terraform + CI/CD

---

**🚀 Happy Terraforming!**
